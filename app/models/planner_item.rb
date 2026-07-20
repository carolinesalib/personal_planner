class PlannerItem < ApplicationRecord
  belongs_to :user
  belongs_to :planner_category

  validates :title, presence: true

  scope :ordered, -> { order(:position, :created_at) }
  scope :open, -> { where(completed: false) }

  def complete!
    update!(completed: true)
  end

  def restore!
    update!(completed: false)
  end
end
