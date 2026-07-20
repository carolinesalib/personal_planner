class PlannerPeriod < ApplicationRecord
  belongs_to :user

  validates :period_type, :period_key, presence: true
  validates :period_type, inclusion: { in: %w[week quarter year] }

  def self.find_or_create_for(user, period_type, period_key)
    find_or_create_by!(user: user, period_type: period_type, period_key: period_key)
  end
end
