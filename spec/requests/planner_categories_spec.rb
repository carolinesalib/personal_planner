require "rails_helper"

RSpec.describe "PlannerCategories", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "POST /planner_categories" do
    it "creates a category for the given period" do
      post planner_categories_path,
        params: { planner_category: { title: "New goals", period_type: "quarter", period_key: "2026-Q3" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(PlannerCategory.find_by(user: user, title: "New goals", period_type: "quarter", period_key: "2026-Q3")).to be_present
    end
  end

  describe "PATCH /planner_categories/:id" do
    it "renames the category" do
      category = create(:planner_category, user: user, title: "Old name")

      patch planner_category_path(category),
        params: { planner_category: { title: "New name" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(category.reload.title).to eq("New name")
    end
  end

  describe "DELETE /planner_categories/:id" do
    it "removes the category and its items" do
      category = create(:planner_category, user: user)
      item = create(:planner_item, user: user, planner_category: category)

      delete planner_category_path(category), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(PlannerCategory.exists?(category.id)).to be false
      expect(PlannerItem.exists?(item.id)).to be false
    end

    it "does not allow deleting another user's category" do
      other_user = create(:user)
      other_category = create(:planner_category, user: other_user)

      delete planner_category_path(other_category)

      expect(response).to have_http_status(:not_found)
    end
  end
end
