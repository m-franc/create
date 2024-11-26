class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:project_id]
      @project = Project.find(params[:project_id])
      @conversations = @project.conversations
    else
      @conversations = Conversation.all
    end
  end

  def show
    if params[:project_id]
      @project = Project.find(params[:project_id])
      @conversation = @project.conversations.find(params[:id])
    else
      @conversation = Conversation.find(params[:id])
    end

    @messages = @conversation.messages.order(created_at: :asc)
    @message = Message.new
  end

  def new
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id]) # Ensure project belongs to the user
      if @project
        @conversation = @project.conversations.build
      else
        redirect_to projects_path, alert: "Project not found or not accessible."
      end
    else
      @conversation = Conversation.new
    end
  end

  def create
    if params[:project_id]
      @project = Project.find(params[:project_id])
      @conversation = @project.conversations.build(conversation_params)
    else
      @conversation = Conversation.new(conversation_params)
    end

    if @conversation.save
      redirect_to @conversation, notice: "Conversation created successfully."
    else
      render :new, alert: "Failed to create conversation."
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name)
  end
end
