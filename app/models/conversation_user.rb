class ConversationUser < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :user_id, uniqueness: { scope: :conversation_id, message: "is already in this conversation" }
  validate :validate_user_access

  private

  def validate_user_access
    if conversation.project.present? && !conversation.project.member?(user)
      errors.add(:user, "must be a member of the project to join this conversation")
    end
  end
end
