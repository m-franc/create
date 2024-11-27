class Project < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  has_many :project_users, dependent: :destroy
  has_many :notes, dependent: :destroy

  has_one :conversation, dependent: :destroy

  after_create :create_conversation

  private

  def create_conversation
    Conversation.create(project: self)
  end
end
