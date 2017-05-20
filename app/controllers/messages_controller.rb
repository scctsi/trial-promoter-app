class MessagesController < ApplicationController
  def edit_campaign_id
    message = Message.find(params[:id])
    authorize message
    message.campaign_id = params[:campaign_id]
    message.save
    respond_to do |format|
      format.html{ redirect_to root_url }
      format.json{ render json: {success: true } }
    end
  end
end
