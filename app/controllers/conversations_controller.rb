class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]
  before_action :authorize_conversation, only: [:show]

  def index
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      if @project
        @conversations = @project.conversations
      else
        redirect_to projects_path, alert: "Project not found or not accessible."
        return
      end
    else
      @conversations = current_user.conversations.distinct
    end
  end

  def show
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @message = Message.new

    respond_to do |format|
      format.html # For full-page loads
      format.turbo_stream # For Turbo Stream updates
    end
  end

  def new
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      if @project
        @conversation = @project.conversations.build
      else
        redirect_to projects_path, alert: "Project not found or not accessible."
        return
      end
    else
      @conversation = Conversation.new
    end
  end

  def create
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      return redirect_to projects_path, alert: "Project not found." unless @project
      @conversation = @project.conversations.build(conversation_params)
    else
      @conversation = Conversation.new(conversation_params)
    end

    if @conversation.save
      # Create initial system message
      @conversation.messages.create!(
        content: "Conversation started",
        user: current_user
      )

      respond_to do |format|
        format.html { redirect_to @conversation, notice: "Conversation was successfully created." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "new_conversation_form",
            partial: "conversations/form",
            locals: { conversation: @conversation }
          )
        }
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def authorize_conversation
    unless @conversation.users.include?(current_user) ||
           (@conversation.project && @conversation.project.user == current_user)
      redirect_to conversations_path, alert: "You don't have access to this conversation."
    end
  end

  def conversation_params
    params.require(:conversation).permit(:name)
  end
end
