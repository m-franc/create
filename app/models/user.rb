class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include PgSearch::Model

  has_many :owned_projects, class_name: "Project", dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :joined_projects, through: :project_users, source: :project
  has_many :messages, dependent: :destroy
  has_many :conversations, through: :messages
  has_many :projects, through: :project_users

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :small, resize_to_fill: [32, 32]
  end

  after_commit :process_avatar, on: [:create, :update]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  multisearchable against: [:email, :username],
                  additional_attributes: ->(user) { { searchable_type: 'User' } }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name
      user.avatar_url = auth.info.image
      user.username = auth.info.email.split('@').first
    end
  end

  private

  def process_avatar
    return unless avatar.attached?

    # Ensure avatar is processed through Cloudinary
    avatar.variant(:thumb).processed
    avatar.variant(:small).processed
  end
end
