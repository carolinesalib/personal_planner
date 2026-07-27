require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  describe "login redirect (wizard only on first login)" do
    def mock_auth_for(user)
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: { email: user.email, name: user.name }
      )
    end

    it "sends a brand-new user to the onboarding wizard" do
      user = create(:user, :onboarding_pending)
      mock_auth_for(user)

      get "/auth/google_oauth2/callback"

      expect(response).to redirect_to(onboarding_path)
    end

    it "sends a returning user straight to root" do
      user = create(:user) # onboarding_completed: true by default
      mock_auth_for(user)

      get "/auth/google_oauth2/callback"

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /onboarding" do
    it "renders for a user who hasn't finished onboarding" do
      sign_in(create(:user, :onboarding_pending))

      get onboarding_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects to root once onboarding is complete" do
      sign_in(create(:user)) # already completed

      get onboarding_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /onboarding/complete" do
    it "marks onboarding complete and enables gratitude when opted in" do
      user = create(:user, :onboarding_pending)
      sign_in(user)

      post onboarding_complete_path, params: { gratitude_enabled: "1" }

      expect(response).to redirect_to(root_path)
      expect(user.reload.onboarding_completed).to be true
      expect(user.gratitude_enabled).to be true
    end

    it "marks onboarding complete and leaves gratitude off when not opted in" do
      user = create(:user, :onboarding_pending)
      sign_in(user)

      post onboarding_complete_path

      expect(response).to redirect_to(root_path)
      expect(user.reload.onboarding_completed).to be true
      expect(user.gratitude_enabled).to be false
    end
  end
end
