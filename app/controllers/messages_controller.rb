class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('message_form', partial: 'messages/form', locals: { message: @message }) }
        format.html { redirect_to @conversation, alert: 'Message cannot be blank.' }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
