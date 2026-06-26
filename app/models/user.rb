class User < ApplicationRecord
  has_many :shoulds, dependent: :destroy
  has_many :plan_items, dependent: :destroy

  validates :provider, :uid, :email, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.from_omniauth(auth)
    find_or_initialize_by(provider: auth.provider, uid: auth.uid).tap do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.avatar_url = auth.info.image
      user.save!
    end
  end
end
