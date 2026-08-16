module Planner
  # Wipes a period's categories (and their items, via dependent: :destroy) and
  # rebuilds it one of two ways:
  #
  #   "previous" - copy the most recent prior period's categories and open items
  #   "scratch"  - lay down the default categories with empty checklists
  #
  # Backs the "reset week" button, which lets the user start a filled-in week
  # over without deleting each item by hand.
  class PeriodReset
    STRATEGIES = %w[previous scratch].freeze

    def self.call(user:, period_type:, period_key:, strategy:)
      new(user: user, period_type: period_type, period_key: period_key, strategy: strategy).call
    end

    def initialize(user:, period_type:, period_key:, strategy:)
      @user = user
      @period_type = period_type
      @period_key = period_key
      @strategy = strategy
    end

    def call
      raise ArgumentError, "unknown strategy: #{@strategy.inspect}" unless STRATEGIES.include?(@strategy)

      ActiveRecord::Base.transaction do
        clear_period

        seeder = PeriodSeeder.new(user: @user, period_type: @period_type, period_key: @period_key)
        # "previous" with no prior period to copy would leave the week completely
        # blank, so fall back to the defaults. The UI hides that choice in this
        # case, but the endpoint is reachable on its own.
        if @strategy == "previous" && seeder.previous_period_categories?
          seeder.copy_from_previous
        else
          seeder.seed_default_categories
        end
      end
    end

    private

    def clear_period
      # destroy_all rather than delete_all so planner_items go with their
      # categories through dependent: :destroy.
      PlannerCategory
        .where(user: @user, period_type: @period_type, period_key: @period_key)
        .destroy_all
    end
  end
end
