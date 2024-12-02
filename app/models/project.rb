class Project < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :project_users, dependent: :destroy
  has_many :joined_users, through: :project_users, source: :user
  has_many :documents, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true
  validates :description, presence: true

  multisearchable against: [:name, :description],
                  additional_attributes: ->(project) { { searchable_type: 'Project' } }

  def owner
    user
  end

  def members
    joined_users
  end

  def member?(user)
    user == self.user || joined_users.include?(user)
  end
end
