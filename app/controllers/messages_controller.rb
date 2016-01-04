class MessagesController < ApplicationController

  respond_to :json

  def index
    @purchase_request = PurchaseRequest.find(params[:request_id])
    @messages = @purchase_request.messages
  end

  def create
    model = params[:model_type].classify.constantize
    msg = Message.new body: params[:body], attachment: params[:attachment]
    msg.user = current_user
    msg.messagable = model.find(params[:model_id]) unless params[:model_id].blank?
    if msg.save
      render json: {message_id: msg.id, attachment_url: msg.attachment.url}, status: :created
    else
      render json: {error: 'Failed to add message'}, status: :unprocessable_entity
    end
  end

end