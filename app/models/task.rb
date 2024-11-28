class Task < ApplicationRecord
  include PgSearch::Model

  belongs_to :project_user
  has_one :project, through: :project_user
  has_one :user, through: :project_user

  validates :name, presence: true
  validates :description, presence: true

  multisearchable against: [:name, :description],
                  additional_attributes: ->(task) { { searchable_type: 'Task' } }
end
