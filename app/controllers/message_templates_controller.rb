class MessageTemplatesController < ApplicationController
  def index
    @message_templates = MessageTemplate.all
  end
  
  def new
    @message_template = MessageTemplate.new
  end
  
  def create
    MessageTemplate.create!(message_template_params)
    redirect_to message_templates_url
  end

private 
  def message_template_params
    # TODO: Unit test this
    params[:message_template].permit(:content, :platform) 
  end
end
