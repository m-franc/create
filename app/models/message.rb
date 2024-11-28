class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true  # Make user optional for system messages

  validates :content, presence: true
  validate :user_required_unless_system_message
  
  scope :system_messages, -> { where(system_message: true) }
  scope :user_messages, -> { where(system_message: false) }
  
  after_create_commit -> { 
    broadcast_append_later_to conversation,
                            target: "messages_conversation_#{conversation.id}",
                            partial: "messages/message",
                            locals: { current_user: user }
  }

  private

  def user_required_unless_system_message
    if !system_message && user.nil?
      errors.add(:user, "is required for non-system messages")
    end
  end
end
