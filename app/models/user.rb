class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :owned_projects, class_name: "Project", dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :joined_projects, through: :project_users, source: :project

  has_one_attached :profile_image

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
end
