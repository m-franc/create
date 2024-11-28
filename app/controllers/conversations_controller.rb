class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :add_participant, :remove_participant]
  before_action :authorize_conversation, only: [:show]

  def index
    load_conversations
  end

  def show
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
    
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

      # Load necessary data for the response
      load_conversations
      @messages = @conversation.messages.includes(:user).order(created_at: :asc)
      @message = Message.new

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

  def add_participant
    user = User.find(params[:user_id])
    
    respond_to do |format|
      if @conversation.add_participant(user)
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "conversation_header",
            partial: "conversations/header",
            locals: { conversation: @conversation }
          )
        }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { message: @conversation.errors.full_messages.join(", "), type: "error" }
          )
        }
      end
    end
  end

  def remove_participant
    user = User.find(params[:user_id])
    
    respond_to do |format|
      if @conversation.remove_participant(user)
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "conversation_header",
            partial: "conversations/header",
            locals: { conversation: @conversation }
          )
        }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { message: "Cannot remove participant with existing messages", type: "error" }
          )
        }
      end
    end
  end

  private

  def load_conversations
    @conversations = if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      @project ? @project.conversations : []
    else
      current_user.conversations.distinct
    end
  end

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
    params.require(:conversation).permit(:name, :project_id)
  end
end
