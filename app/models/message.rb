class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true

  validates :content, presence: true

  after_create_commit -> {
    broadcast_append_later_to conversation,
      target: "messages_conversation_#{conversation.id}",
      partial: "messages/message",
      locals: { message: self, current_user: user }
  }

  def system_message?
    system_message == true
  end
end
