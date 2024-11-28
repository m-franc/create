class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append(
            "messages_conversation_#{@conversation.id}",
            partial: "messages/message",
            locals: { message: @message, current_user: current_user }
          )
        }
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update(
            "flash",
            partial: "shared/flash",
            locals: { flash: { alert: "Message cannot be blank." } }
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
  end

  def authorize_conversation
    unless @conversation.participant?(current_user)
      redirect_to root_path, alert: "You don't have access to this conversation"
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
