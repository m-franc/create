class Task < ApplicationRecord
  belongs_to :user
  belongs_to :project
  include PgSearch::Model

  validates :name, presence: true
  validates :description, presence: true

  multisearchable against: [:name, :description],
                  additional_attributes: ->(task) { { searchable_type: 'Task' } }

  def formatted_deadline
    return nil unless deadline.present?
    deadline.is_a?(String) ? Date.parse(deadline) : deadline
  end
end
