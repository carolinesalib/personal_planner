require "rails_helper"

RSpec.describe "PlannerWeeks", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "GET /plan/week" do
    it "seeds default categories on first visit" do
      get planner_week_path

      expect(response).to have_http_status(:ok)
      expect(PlannerCategory.where(user: user, period_type: "week").count).to eq(6)
    end

    it "does not reseed on a second visit" do
      get planner_week_path
      get planner_week_path

      expect(PlannerCategory.where(user: user, period_type: "week").count).to eq(6)
    end
  end

  describe "GET /plan/week/:date" do
    it "carries over open items from the prior week when first visited" do
      prior_monday = Date.new(2026, 7, 6)
      prior_key = Planner::PeriodKey.week_key(prior_monday)
      category = create(:planner_category, user: user, period_type: "week", period_key: prior_key, title: "Personal")
      create(:planner_item, user: user, planner_category: category, title: "Unfinished", completed: false)
      create(:planner_item, user: user, planner_category: category, title: "Finished", completed: true)

      next_monday = prior_monday + 7
      get planner_week_on_path(date: next_monday.iso8601)

      expect(response.body).to include("Unfinished")
      expect(response.body).not_to include("Finished")
    end
  end
end
