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

  describe "the clear-week button" do
    it "is shown on the current week" do
      get planner_week_path

      expect(response.body).to include("Clear week")
    end

    it "is shown on a future week even when it has nothing in it" do
      # An empty future week is still resettable, so this week's plan can be
      # copied forward to plan ahead.
      get planner_week_on_path(date: (Date.current + 21).iso8601)

      expect(response.body).to include("Clear week")
    end

    it "is hidden on a past week" do
      get planner_week_on_path(date: (Date.current - 7).iso8601)

      expect(response.body).not_to include("Clear week")
    end

    it "is hidden on a past week that has a plan" do
      past_monday = Planner::PeriodKey.monday_of(Date.current - 7)
      category = create(:planner_category, user: user, period_type: "week",
                        period_key: Planner::PeriodKey.week_key(past_monday), title: "Personal")
      create(:planner_item, user: user, planner_category: category, title: "Something")

      get planner_week_on_path(date: past_monday.iso8601)

      expect(response.body).not_to include("Clear week")
    end
  end

  describe "DELETE /plan/week/:date/reset" do
    # Resetting is only allowed from the current week onward, so anchor on today.
    let(:monday) { Planner::PeriodKey.monday_of(Date.current) }
    let(:period_key) { Planner::PeriodKey.week_key(monday) }

    # The week being reset, filled in with a category and an item.
    def fill_current_week
      category = create(:planner_category, user: user, period_type: "week", period_key: period_key, title: "Old category")
      create(:planner_item, user: user, planner_category: category, title: "Old item")
      category
    end

    # The week before it, which "copy from last week" should pull from.
    def fill_prior_week
      prior_key = Planner::PeriodKey.week_key(monday - 7)
      category = create(:planner_category, user: user, period_type: "week", period_key: prior_key, title: "Carried category")
      create(:planner_item, user: user, planner_category: category, title: "Carried open", completed: false)
      create(:planner_item, user: user, planner_category: category, title: "Carried done", completed: true)
      category
    end

    it "replaces the week with the default categories when starting from scratch" do
      fill_current_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "scratch" }

      categories = PlannerCategory.where(user: user, period_type: "week", period_key: period_key)
      expect(categories.pluck(:title)).to eq(Planner::PeriodSeeder::DEFAULT_TITLES.fetch("week"))
      expect(PlannerItem.where(planner_category: categories)).to be_empty
    end

    it "copies the prior week's categories and open items when copying from before" do
      fill_current_week
      fill_prior_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "previous" }

      categories = PlannerCategory.where(user: user, period_type: "week", period_key: period_key)
      expect(categories.pluck(:title)).to eq([ "Carried category" ])
      expect(PlannerItem.where(planner_category: categories).pluck(:title)).to eq([ "Carried open" ])
    end

    it "removes the previous contents of the week" do
      old_category = fill_current_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "scratch" }

      expect(PlannerCategory.where(id: old_category.id)).to be_empty
      expect(PlannerItem.where(planner_category_id: old_category.id)).to be_empty
    end

    it "falls back to the defaults when asked to copy with no prior week" do
      fill_current_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "previous" }

      categories = PlannerCategory.where(user: user, period_type: "week", period_key: period_key)
      expect(categories.pluck(:title)).to eq(Planner::PeriodSeeder::DEFAULT_TITLES.fetch("week"))
    end

    it "leaves the week untouched when the strategy is not recognised" do
      fill_current_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "nonsense" }

      categories = PlannerCategory.where(user: user, period_type: "week", period_key: period_key)
      expect(categories.pluck(:title)).to eq([ "Old category" ])
    end

    it "refuses to clear a past week" do
      past_monday = monday - 7
      past_key = Planner::PeriodKey.week_key(past_monday)
      category = create(:planner_category, user: user, period_type: "week", period_key: past_key, title: "Old category")
      create(:planner_item, user: user, planner_category: category, title: "Old item")

      delete planner_week_reset_path(date: past_monday.iso8601), params: { strategy: "scratch" }

      expect(PlannerCategory.where(user: user, period_type: "week", period_key: past_key).pluck(:title)).to eq([ "Old category" ])
      expect(PlannerItem.where(planner_category: category).pluck(:title)).to eq([ "Old item" ])
    end

    it "clears a future week and copies the most recent planned week forward" do
      # This week's plan is what a future week should pull from.
      current_category = create(:planner_category, user: user, period_type: "week", period_key: period_key, title: "This week")
      create(:planner_item, user: user, planner_category: current_category, title: "Carry me", completed: false)
      create(:planner_item, user: user, planner_category: current_category, title: "Already done", completed: true)

      future_monday = monday + 14
      future_key = Planner::PeriodKey.week_key(future_monday)

      delete planner_week_reset_path(date: future_monday.iso8601), params: { strategy: "previous" }

      categories = PlannerCategory.where(user: user, period_type: "week", period_key: future_key)
      expect(categories.pluck(:title)).to eq([ "This week" ])
      expect(PlannerItem.where(planner_category: categories).pluck(:title)).to eq([ "Carry me" ])
    end

    it "does not touch another user's week" do
      other_user = create(:user)
      other_category = create(:planner_category, user: other_user, period_type: "week", period_key: period_key, title: "Theirs")
      create(:planner_item, user: other_user, planner_category: other_category, title: "Their item")
      fill_current_week

      delete planner_week_reset_path(date: monday.iso8601), params: { strategy: "scratch" }

      expect(PlannerCategory.where(id: other_category.id).pluck(:title)).to eq([ "Theirs" ])
      expect(PlannerItem.where(planner_category_id: other_category.id).pluck(:title)).to eq([ "Their item" ])
    end
  end
end
