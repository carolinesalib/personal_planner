FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    sequence(:uid) { |n| "uid_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    gratitude_enabled { false }
    onboarding_completed { true }
  end
end
