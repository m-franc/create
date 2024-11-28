class Note < ApplicationRecord
  include PgSearch::Model

  belongs_to :project
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true

  multisearchable against: [:title, :content],
                  additional_attributes: ->(note) { { searchable_type: 'Note' } }
end
