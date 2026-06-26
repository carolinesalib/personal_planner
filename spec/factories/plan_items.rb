FactoryBot.define do
  factory :plan_item do
    user
    date { Date.current }
    kind { "priority" }
    sequence(:title) { |n| "Plan item #{n}" }
    completed { false }
  end
end
