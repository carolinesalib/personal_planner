FactoryBot.define do
  factory :planner_item do
    user
    planner_category
    sequence(:title) { |n| "Item #{n}" }
    completed { false }
    position { 0 }
  end
end
