class LoginToken < ApplicationRecord
  belongs_to :user

  before_create :generate_token

  EXPIRY = 5.minutes

  def self.exchange(raw_token)
    token = find_by(token: raw_token)
    return nil if token.nil? || token.expires_at < Time.current

    user = token.user
    token.destroy
    user
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = EXPIRY.from_now
  end
end
