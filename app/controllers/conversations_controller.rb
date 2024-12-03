class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :add_participant, :remove_participant]

  def index
    load_conversations
    if params[:selected].present?
      @conversation = @conversations.find_by(id: params[:selected])
      @messages = @conversation.messages.includes(:user) if @conversation
      @new_message = Message.new
    end
  end

  def show
    unless @conversation.participant?(current_user)
      redirect_to root_path, alert: "You don't have access to this conversation"
      return
    end

    @messages = @conversation.messages.includes(:user)
    @new_message = Message.new
    @project = @conversation.project

    # Always render the full page for project conversations
    @conversations = current_user.conversations.includes(:messages)
    render :show
  end

  def new
    if params[:project_id]
      @project = current_user.projects.find_by(id: params[:project_id])
      return redirect_to projects_path, alert: "Project not found." unless @project
      @conversation = @project.conversations.build
    else
      @conversation = Conversation.new
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("new_conversation_form", partial: "conversations/form") }
    end
  end

  def create
    @conversation = if params[:project_id].present?
      project = current_user.projects.find(params[:project_id])
      project.conversations.build(conversation_params)
    else
      Conversation.new(conversation_params)
    end

    if @conversation.save
      # Add creator as participant
      ConversationUser.create(conversation: @conversation, user: current_user)
      
      # Add selected participants
      if params[:conversation][:participant_ids].present?
        params[:conversation][:participant_ids].each do |user_id|
          next if user_id.blank?
          user = User.find(user_id)
          ConversationUser.create(conversation: @conversation, user: user)
        end
      end

      if @conversation.project
        redirect_to project_path(@conversation.project, anchor: 'conversations-tab'), 
                    notice: 'Conversation was successfully created.'
      else
        redirect_to conversation_path(@conversation), 
                    notice: 'Conversation was successfully created.'
      end
    else
      flash.now[:alert] = @conversation.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
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
            locals: { alert: @conversation.errors.full_messages.join(", ") }
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
            locals: { alert: "Cannot remove participant with existing messages" }
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
    params.require(:conversation).permit(:name, :project_id, participant_ids: [])
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
          locals: { alert: @conversation.errors.full_messages.join(", ") }
        )
      end
    end
  end
end
