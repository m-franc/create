class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :owned_projects, class_name: "Project", dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :joined_projects, through: :project_users, source: :project
  has_many :messages, dependent: :destroy
  has_many :conversations, through: :messages
  has_one_attached :profile_image
  has_many :projects, through: :project_users
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  class User < ApplicationRecord
    include PgSearch::Model

    pg_search_scope :search_by_name_and_email,
                    against: [:name, :email], # Colonnes à rechercher
                    using: {
                      tsearch: { prefix: true } # Recherche sur les débuts de mots
                    }
  end

end
