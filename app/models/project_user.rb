class ProjectUser < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_many :tasks
end
