class Conversation < ApplicationRecord
  belongs_to :project, optional: true
  has_many :messages, dependent: :destroy
  has_many :users, through: :messages

  
end
