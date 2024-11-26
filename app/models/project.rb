class Project < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_one :conversation, dependent: :destroy

  after_create :create_conversation

  private

  def create_conversation
    Conversation.create(project: self)
  end
end
