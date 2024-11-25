class Conversation < ApplicationRecord
  belongs_to :project
  has_many :messages, dependent: :destroy
end
