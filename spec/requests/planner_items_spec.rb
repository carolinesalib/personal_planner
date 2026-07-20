require "rails_helper"

RSpec.describe "PlannerItems", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:planner_category, user: user) }

  before { sign_in(user) }

  describe "POST /planner_items" do
    it "creates an item under the category" do
      post planner_items_path,
        params: { planner_item: { title: "Do the thing", planner_category_id: category.id } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(category.planner_items.find_by(title: "Do the thing")).to be_present
    end
  end

  describe "PATCH /planner_items/:id/toggle" do
    it "toggles completion" do
      item = create(:planner_item, user: user, planner_category: category, completed: false)

      patch toggle_planner_item_path(item), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(item.reload.completed).to be true
    end
  end

  describe "DELETE /planner_items/:id" do
    it "does not allow deleting another user's item" do
      other_user = create(:user)
      other_category = create(:planner_category, user: other_user)
      other_item = create(:planner_item, user: other_user, planner_category: other_category)

      delete planner_item_path(other_item)

      expect(response).to have_http_status(:not_found)
    end
  end
end
