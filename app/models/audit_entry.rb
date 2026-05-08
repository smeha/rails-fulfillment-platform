class AuditEntry < ApplicationRecord
  belongs_to :auditable, polymorphic: true
  belongs_to :actor, polymorphic: true, optional: true

  before_validation :set_defaults
  before_destroy :prevent_destroy

  validates :action, :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc, created_at: :desc) }

  private

  def set_defaults
    self.occurred_at ||= Time.current
    self.metadata ||= {}
  end

  def prevent_destroy
    raise ActiveRecord::ReadOnlyRecord, "AuditEntry records are immutable"
  end
end
