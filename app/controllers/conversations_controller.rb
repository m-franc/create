class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = Project.find(params[:project_id])
    @conversation = @project.conversation
    @messages = @conversation.messages.order(created_at: :asc)
    @message = Message.new
  end
end
