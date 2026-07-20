module Planner
  # Seeds a newly-opened week/quarter/year with categories (and carries over
  # open items) from the most recent prior period that has data, so the user
  # doesn't start from a blank slate every time. Runs once per period, the
  # first time it's opened.
  class PeriodSeeder
    DEFAULT_TITLES = {
      "week" => [ "Personal", "Career goals", "Health goals", "Social goals", "House", "Other" ],
      "quarter" => [ "Goals" ],
      "year" => [ "Goals" ]
    }.freeze

    def self.call(user:, period_type:, period_key:)
      new(user: user, period_type: period_type, period_key: period_key).call
    end

    def initialize(user:, period_type:, period_key:)
      @user = user
      @period_type = period_type
      @period_key = period_key
    end

    def call
      return if PlannerCategory.where(user: @user, period_type: @period_type, period_key: @period_key).exists?

      prior_categories = previous_period_categories
      if prior_categories.empty?
        seed_defaults
      else
        seed_from(prior_categories)
      end
    end

    private

    def previous_period_categories
      PlannerCategory
        .where(user: @user, period_type: @period_type)
        .where("period_key < ?", @period_key)
        .order(period_key: :desc)
        .then { |scope| scope.where(period_key: scope.limit(1).pick(:period_key)) }
        .ordered
    end

    def seed_defaults
      DEFAULT_TITLES.fetch(@period_type).each_with_index do |title, index|
        PlannerCategory.create!(
          user: @user, period_type: @period_type, period_key: @period_key,
          title: title, position: index
        )
      end
    end

    def seed_from(prior_categories)
      prior_categories.each_with_index do |prior_category, index|
        new_category = PlannerCategory.create!(
          user: @user, period_type: @period_type, period_key: @period_key,
          title: prior_category.title, position: index
        )

        prior_category.planner_items.open.ordered.each_with_index do |prior_item, item_index|
          PlannerItem.create!(
            user: @user, planner_category: new_category,
            title: prior_item.title, position: item_index
          )
        end
      end
    end
  end
end
