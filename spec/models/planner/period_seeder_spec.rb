require "rails_helper"

RSpec.describe Planner::PeriodSeeder do
  let(:user) { create(:user) }

  describe ".call" do
    context "when no prior period has data" do
      it "seeds default categories for a week" do
        described_class.call(user: user, period_type: "week", period_key: "2026-W10")

        titles = PlannerCategory.where(user: user, period_type: "week", period_key: "2026-W10").order(:position).pluck(:title)
        expect(titles).to eq([ "Personal", "Career goals", "Health goals", "Social goals", "House", "Other" ])
      end

      it "seeds a single default category for a quarter" do
        described_class.call(user: user, period_type: "quarter", period_key: "2026-Q1")

        titles = PlannerCategory.where(user: user, period_type: "quarter", period_key: "2026-Q1").pluck(:title)
        expect(titles).to eq([ "Goals" ])
      end
    end

    context "when a prior period has data" do
      it "copies category names into the new period" do
        prior = create(:planner_category, user: user, period_type: "week", period_key: "2026-W09", title: "Personal", position: 0)

        described_class.call(user: user, period_type: "week", period_key: "2026-W10")

        new_category = PlannerCategory.find_by(user: user, period_type: "week", period_key: "2026-W10")
        expect(new_category.title).to eq("Personal")
        expect(new_category.id).not_to eq(prior.id)
      end

      it "carries over incomplete items but not completed ones" do
        prior = create(:planner_category, user: user, period_type: "week", period_key: "2026-W09", title: "Personal")
        open_item = create(:planner_item, user: user, planner_category: prior, title: "Open task", completed: false)
        create(:planner_item, user: user, planner_category: prior, title: "Done task", completed: true)

        described_class.call(user: user, period_type: "week", period_key: "2026-W10")

        new_category = PlannerCategory.find_by(user: user, period_type: "week", period_key: "2026-W10")
        carried_titles = new_category.planner_items.pluck(:title)

        expect(carried_titles).to contain_exactly("Open task")
        expect(carried_titles).not_to include("Done task")
        expect(new_category.planner_items.find_by(title: "Open task")).not_to eq(open_item)
        expect(new_category.planner_items.find_by(title: "Open task").completed).to be false
      end

      it "finds the most recent prior period, not just any prior period" do
        create(:planner_category, user: user, period_type: "week", period_key: "2026-W05", title: "Old")
        create(:planner_category, user: user, period_type: "week", period_key: "2026-W09", title: "Recent")

        described_class.call(user: user, period_type: "week", period_key: "2026-W10")

        titles = PlannerCategory.where(user: user, period_type: "week", period_key: "2026-W10").pluck(:title)
        expect(titles).to eq([ "Recent" ])
      end
    end

    context "when the period already has categories" do
      it "does not seed again" do
        create(:planner_category, user: user, period_type: "week", period_key: "2026-W10", title: "Custom")

        described_class.call(user: user, period_type: "week", period_key: "2026-W10")

        titles = PlannerCategory.where(user: user, period_type: "week", period_key: "2026-W10").pluck(:title)
        expect(titles).to eq([ "Custom" ])
      end
    end
  end
end
