FactoryBot.define do
  factory :planner_period do
    user
    period_type { "week" }
    period_key { "2026-W01" }
    mission { nil }
  end
end
