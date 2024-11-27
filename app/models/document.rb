class Document < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :name, presence: true
  validates :cloudinary_id, presence: true, if: -> { file.present? }

  attr_accessor :file
end
