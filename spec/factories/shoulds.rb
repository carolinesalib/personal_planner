FactoryBot.define do
  factory :should do
    user
    sequence(:title) { |n| "Should item #{n}" }
    completed { false }
  end
end
