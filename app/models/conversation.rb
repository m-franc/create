class Conversation < ApplicationRecord
  belongs_to :project, optional: true
  has_many :messages, dependent: :destroy
  has_many :conversation_users, dependent: :destroy
  has_many :participants, through: :conversation_users, source: :user
  has_many :users, through: :messages


  validates :name, presence: true

  def add_participant(user)
    return false if participants.include?(user)

    conversation_user = conversation_users.new(user: user)
    if conversation_user.save
      true
    else
      errors.merge!(conversation_user.errors)
      false
    end
  end

  def remove_participant(user)
    return false if messages.where(user: user).exists?
    conversation_users.find_by(user: user)&.destroy
  end

  def participant?(user)
    participants.include?(user)
  end

  def can_add_participant?(user)
    return false if participant?(user)
    project.nil? || project.member?(user)
  end
end
