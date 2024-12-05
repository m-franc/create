class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]
  has_many :tasks
  
  def index
    @users = User.all
  end

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
