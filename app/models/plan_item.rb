class PlanItem < ApplicationRecord
  belongs_to :user

  validates :date, :kind, :title, presence: true
  validates :kind, inclusion: { in: %w[priority extra gratitude] }

  scope :priorities, -> { where(kind: "priority").order(:position, :created_at) }
  scope :extras, -> { where(kind: "extra").order(:position, :created_at) }
  scope :gratitudes, -> { where(kind: "gratitude").order(:position, :created_at) }
  scope :for_date, ->(date) { where(date: date) }
  scope :trackable, -> { where(kind: %w[priority extra]) }
end
