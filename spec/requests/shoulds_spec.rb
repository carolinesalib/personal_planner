require "rails_helper"

RSpec.describe "Shoulds", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "DELETE /shoulds/:id" do
    context "when deleting an active should" do
      it "removes the item and updates counts" do
        should_item = create(:should, user: user, title: "Buy groceries")
        create(:should, user: user, completed: true, completed_at: 1.day.ago)

        delete should_path(should_item), headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(Should.exists?(should_item.id)).to be false
        expect(response.body).to include("shoulds-badge")
        expect(response.body).to include("done-count")
      end
    end

    context "when deleting a completed should" do
      it "removes the item and updates the done subtitle" do
        should_item = create(:should, user: user, title: "Clean kitchen", completed: true, completed_at: 1.hour.ago)
        create(:should, user: user, title: "Other done task", completed: true, completed_at: 2.hours.ago)

        delete should_path(should_item), headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(Should.exists?(should_item.id)).to be false
        expect(response.body).to include("done-subtitle")
        expect(response.body).to include("1 thing checked off")
      end
    end
  end

  describe "PATCH /shoulds/:id/restore" do
    it "restores the item and updates the done subtitle" do
      should_item = create(:should, user: user, title: "Restored task", completed: true, completed_at: 1.hour.ago)
      create(:should, user: user, title: "Still done", completed: true, completed_at: 2.hours.ago)

      patch restore_should_path(should_item), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      should_item.reload
      expect(should_item.completed).to be false
      expect(response.body).to include("done-subtitle")
      expect(response.body).to include("1 thing checked off")
    end
  end

  describe "DELETE /shoulds/:id" do
    it "does not allow deleting another user's should" do
      other_user = create(:user)
      other_should = create(:should, user: other_user, title: "Not mine")

      delete should_path(other_should)

      expect(response).to have_http_status(:not_found)
    end
  end
end
