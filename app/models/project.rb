class Project < ApplicationRecord
  belongs_to :user
  has_one_attached :image
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
