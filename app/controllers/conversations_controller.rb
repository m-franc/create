class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :add_participant, :remove_participant]

  def index
    load_conversations
  end

  def show
    unless @conversation.participant?(current_user)
      redirect_to root_path, alert: "You don't have access to this conversation"
      return
    end
    @messages = @conversation.messages.includes(:user)
    @new_message = Message.new
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      return redirect_to projects_path, alert: "Project not found." unless @project
      @conversation = @project.conversations.build
    else
      @conversation = Conversation.new
    end
    # Store the referrer URL for redirect after creation
    session[:return_to] = request.referrer
  end

  def create
    @conversation = params[:project_id] ? build_project_conversation : Conversation.new(conversation_params)
    return redirect_to projects_path, alert: "Project not found." if @conversation.nil?
  
    if @conversation.save
      @conversation.add_participant(current_user)
      @conversation.messages.create!(
        content: "#{current_user.username} has joined the conversation",
        system_message: true,
        user: current_user
      )
      
      # Redirect back to the stored URL or default to conversations path
      redirect_to session.delete(:return_to) || conversations_path
    else
      render_failure_response
    end
  end

  def add_participant
    user = User.find(params[:user_id])
    
    respond_to do |format|
      if @conversation.add_participant(user)
        format.html { redirect_to @conversation, notice: "#{user.username} has been added to the conversation" }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "conversation_header",
            partial: "conversations/header",
            locals: { conversation: @conversation }
          )
        }
      else
        format.html { redirect_to @conversation, alert: @conversation.errors.full_messages.join(", ") }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flashes",
            locals: { flash: { alert: @conversation.errors.full_messages.join(", ") } }
          )
        }
      end
    end
  end

  def remove_participant
    user = User.find(params[:user_id])
    
    respond_to do |format|
      if @conversation.remove_participant(user)
        format.html { redirect_to @conversation, notice: "#{user.username} has been removed from the conversation" }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "conversation_header",
            partial: "conversations/header",
            locals: { conversation: @conversation }
          )
        }
      else
        format.html { redirect_to @conversation, alert: "Cannot remove participant with existing messages" }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flashes",
            locals: { flash: { alert: "Cannot remove participant with existing messages" } }
          )
        }
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:name, :project_id)
  end

  def load_conversations
    @conversations = if params[:project_id]
      project = current_user.projects.find_by(id: params[:project_id])
      project ? project.conversations : Conversation.none
    else
      Conversation.joins(:conversation_users)
                 .where(conversation_users: { user_id: current_user.id })
                 .distinct
    end
  end

  def build_project_conversation
    project = current_user.projects.find_by(id: params[:project_id])
    project&.conversations.build(conversation_params)
  end
  
  def render_failure_response
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "flash",
          partial: "shared/flashes",
          locals: { flash: { alert: @conversation.errors.full_messages.join(", ") } }
        )
      end
    end
  end
end
