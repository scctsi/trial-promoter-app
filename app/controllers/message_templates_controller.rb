class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [:edit, :update]

  def index
    authorize MessageTemplate
    @message_templates = MessageTemplate.all
  end

  def new
    authorize MessageTemplate
    @message_template = MessageTemplate.new
  end

  def edit
    authorize MessageTemplate
    @message_template = MessageTemplate.find(params[:id])
  end

  def create
    @message_template = MessageTemplate.new(message_template_params)
    authorize MessageTemplate

    if @message_template.save
      redirect_to message_templates_url
    else
      render :new
    end
  end

  def update
    authorize MessageTemplate
    if @message_template.update(message_template_params)
      redirect_to message_templates_url
    else
      render :edit
    end
  end

  def import
    authorize MessageTemplate
    experiment = Experiment.find(params[:experiment_id])

    # Read CSV file from a URL
    csv_file_reader = CsvFileReader.new
    parsed_csv_content = csv_file_reader.read(params[:url])

    # Import message templates
    message_template_importer = MessageTemplateImporter.new(parsed_csv_content, experiment.to_param)
    message_template_importer.import

    render json: { success: true, imported_count: parsed_csv_content.length - 1 }
  end

  private

  def set_message_template
    @message_template = MessageTemplate.find(params[:id])
  end

  def message_template_params
    # TODO: Unit test this
    params[:message_template].permit(:content, :platform, :tag_list)
  end
end
