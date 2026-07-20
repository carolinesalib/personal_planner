class PlannerCategory < ApplicationRecord
  belongs_to :user
  has_many :planner_items, -> { order(:position, :created_at) }, dependent: :destroy

  validates :title, :period_type, :period_key, presence: true
  validates :period_type, inclusion: { in: %w[week quarter year] }

  scope :ordered, -> { order(:position, :created_at) }
  scope :for_period, ->(period_type, period_key) { where(period_type: period_type, period_key: period_key).ordered }
end
