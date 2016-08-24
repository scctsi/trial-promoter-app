class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [:edit, :update]
  
  def index
    @message_templates = MessageTemplate.all
  end
  
  def new
    @message_template = MessageTemplate.new
  end
  
  def edit
    @message_template = MessageTemplate.find(params[:id])
  end

  def create
    @message_template = MessageTemplate.new(message_template_params)

    if @message_template.save
      redirect_to message_templates_url
    else
      render :new
    end
  end
  
  def update
  end

  private

  def set_message_template
    @message_template = MessageTemplate.find(params[:id])
  end
  
  def message_template_params
    # TODO: Unit test this
    params[:message_template].permit(:content, :platform) 
  end
end
