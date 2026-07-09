require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  before do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name }
    )
  end

  describe "GET /login" do
    it "stores native flag in session when ?native=1" do
      get login_path, params: { native: "1" }
      expect(session[:native_auth]).to be true
    end

    it "does not set native flag without the param" do
      get login_path
      expect(session[:native_auth]).to be_nil
    end
  end

  describe "GET /auth/google_oauth2/callback" do
    context "web flow" do
      it "sets session user_id and redirects to root" do
        get "/auth/google_oauth2/callback"
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context "native flow" do
      before { get login_path, params: { native: "1" } }

      it "redirects to shouldplanner:// custom scheme with a token" do
        get "/auth/google_oauth2/callback"
        expect(response.location).to start_with("shouldplanner://auth/success?token=")
      end

      it "creates a LoginToken for the user" do
        expect { get "/auth/google_oauth2/callback" }.to change(LoginToken, :count).by(1)
      end

      it "does not set session user_id" do
        get "/auth/google_oauth2/callback"
        expect(session[:user_id]).to be_nil
      end

      it "clears the native_auth session flag" do
        get "/auth/google_oauth2/callback"
        expect(session[:native_auth]).to be_nil
      end
    end
  end

  describe "GET /auth/token_login" do
    context "with a valid token" do
      let!(:login_token) { LoginToken.create!(user: user) }

      it "logs the user in and redirects to root" do
        get "/auth/token_login", params: { token: login_token.token }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
      end

      it "deletes the token after use" do
        expect { get "/auth/token_login", params: { token: login_token.token } }
          .to change(LoginToken, :count).by(-1)
      end
    end

    context "with an expired token" do
      let!(:login_token) { LoginToken.create!(user: user) }

      before { login_token.update!(expires_at: 1.minute.ago) }

      it "redirects to login with an alert" do
        get "/auth/token_login", params: { token: login_token.token }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Login link expired. Please try again.")
      end

      it "does not log the user in" do
        get "/auth/token_login", params: { token: login_token.token }
        expect(session[:user_id]).to be_nil
      end
    end

    context "with an invalid token" do
      it "redirects to login with an alert" do
        get "/auth/token_login", params: { token: "bogus" }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Login link expired. Please try again.")
      end
    end
  end
end
