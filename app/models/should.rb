class Should < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :active, -> { where(completed: false).order(:position, :created_at) }
  scope :done, -> { where(completed: true).order(completed_at: :desc) }

  def complete!
    update!(completed: true, completed_at: Time.current)
  end

  def restore!
    update!(completed: false, completed_at: nil)
  end
end
