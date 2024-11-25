class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to project_conversation_path(@conversation.project)
    else
      redirect_to project_conversation_path(@conversation.project), alert: 'Message cannot be blank.'
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
