module Planner
  # Date <-> period_key helpers shared by the week/quarter/year controllers.
  # Keys are lexicographically sortable strings so PeriodSeeder can find the
  # most recent prior period with a plain `<` comparison.
  module PeriodKey
    module_function

    def week_key(date)
      y, w = date.cwyear, date.cweek
      format("%04d-W%02d", y, w)
    end

    def monday_of(date)
      date.beginning_of_week(:monday)
    end

    def quarter_of(date)
      ((date.month - 1) / 3) + 1
    end

    def quarter_key(year, quarter)
      format("%04d-Q%d", year, quarter)
    end

    def year_key(year)
      format("%04d", year)
    end
  end
end
