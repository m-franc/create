class Project < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  has_many :project_users, dependent: :destroy
  has_many :joined_users, through: :project_users, source: :user
  has_many :users, through: :project_users
  has_one :conversation, dependent: :destroy

  after_create :create_default_conversation

  private

  def create_default_conversation
    conversations.create!(
      name: "#{name} - General Discussion",
      project: self
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create default conversation for project #{id}: #{e.message}"
  end
end
