class Conversation < ApplicationRecord
  belongs_to :project
  has_many :messages, dependent: :destroy
  has_many :conversation_users, dependent: :destroy
  has_many :participants, through: :conversation_users, source: :user
  has_many :users, through: :messages

  validates :name, presence: true

  def add_participant(user)
    return false if participants.include?(user)

    conversation_user = conversation_users.new(user: user)
    if conversation_user.save
      messages.create!(
        content: "#{user.username} has joined the conversation",
        system_message: true,
        user: user
      )
      true
    else
      errors.merge!(conversation_user.errors)
      false
    end
  end

  def remove_participant(user)
    return false if messages.where(user: user).exists?
    if conversation_users.find_by(user: user)&.destroy
      messages.create!(
        content: "#{user.username} has left the conversation",
        system_message: true,
        user: nil  # System message doesn't need a user
      )
      true
    else
      false
    end
  end

  def participant?(user)
    participants.include?(user)
  end

  def can_add_participant?(user)
    return false if participant?(user)
    project.nil? || project.member?(user)
  end

  def visible_messages_for(user)
    return messages if participant?(user)
    messages.where("created_at >= ?", conversation_users.find_by(user: user)&.created_at || Time.current)
  end
end
