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

    respond_to do |format|
      format.html
      format.turbo_stream do
        if params[:selected].present? && @conversation
          render turbo_stream: turbo_stream.update("conversation_messages", partial: "conversation", locals: { conversation: @conversation })
        end
      end
    end
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
    
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("new_conversation_form", partial: "conversations/form") }
    end
  end

  def create
    @conversation = Conversation.new(conversation_params)

    if @conversation.save
      # Add creator as participant first
      creator_participant = ConversationUser.create(conversation: @conversation, user: current_user)
      
      # Add system message about conversation creation
      @conversation.messages.create!(
        content: "#{current_user.username} created the conversation",
        system_message: true,
        user: current_user
      )
      
      # Add selected participants
      if params[:conversation][:participant_ids].present?
        params[:conversation][:participant_ids].reject(&:blank?).each do |user_id|
          user = User.find(user_id)
          ConversationUser.create(conversation: @conversation, user: user)
          @conversation.messages.create!(
            content: "#{user.username} was added to the conversation",
            system_message: true,
            user: current_user
          )
        end
      end

      respond_to do |format|
        format.html { redirect_to conversations_path(selected: @conversation.id), notice: 'Conversation was successfully created.' }
        format.turbo_stream { redirect_to conversations_path(selected: @conversation.id), notice: 'Conversation was successfully created.' }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
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
    @conversations = current_user.conversations
                               .includes(:project, messages: :user)
                               .order(updated_at: :desc)
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
