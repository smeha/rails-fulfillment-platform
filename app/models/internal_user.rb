class InternalUser < ApplicationRecord
  has_secure_password

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :active, inclusion: { in: [ true, false ] }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
