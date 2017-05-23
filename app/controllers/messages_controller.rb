class MessagesController < ApplicationController
  def edit_campaign_id
    message = Message.find(params[:id])
    authorize message
    message.campaign_id = params[:campaign_id]
    message.save
    if request.xhr?
      render 'shared/_message_campaign_id.html.haml', layout: false, locals: { message: message }
    else redirect_to root_path
    end
  end

  def new_campaign_id
    message = Message.find(params[:id])
    authorize message
    if request.xhr?
      render 'shared/forms/_input_message_campaign_id.html.haml', layout: false, locals: { message: message }
    else redirect_to root_path
    end
  end
end
