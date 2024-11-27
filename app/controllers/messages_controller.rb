class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'message_form',
            partial: 'messages/form',
            locals: { message: @message }
          )
        }
        format.html {
          redirect_to @conversation,
          alert: 'Message cannot be blank.'
        }
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: "Conversation not found."
  end

  def authorize_conversation
    unless @conversation.users.include?(current_user) ||
           (@conversation.project && @conversation.project.user == current_user)
      redirect_to conversations_path, alert: "You don't have access to this conversation."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
