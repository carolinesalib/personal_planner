FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    sequence(:uid) { |n| "uid_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    gratitude_enabled { false }
    onboarding_completed { true }

    trait :onboarding_pending do
      onboarding_completed { false }
    end

    trait :with_gratitude do
      gratitude_enabled { true }
    end
  end
end
