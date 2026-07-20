FactoryBot.define do
  factory :planner_category do
    user
    period_type { "week" }
    period_key { "2026-W01" }
    sequence(:title) { |n| "Category #{n}" }
    position { 0 }
  end
end
