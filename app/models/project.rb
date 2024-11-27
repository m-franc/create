class Project < ApplicationRecord
  belongs_to :user
  has_many :project_users
  has_many :users, through: :project_users
  has_many :conversations, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

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
