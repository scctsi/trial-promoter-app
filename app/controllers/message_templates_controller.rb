class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [:get_image_selections, :add_image_to_image_pool, :remove_image_from_image_pool]

  def index
    authorize MessageTemplate
    @message_templates = MessageTemplate.all
  end

  def get_image_selections
    authorize @message_template
    image_pool_manager = ImagePoolManager.new
    experiment = Experiment.find(params[:experiment_id])
    selected_and_unselected_images = image_pool_manager.get_selected_and_unselected_images(experiment, @message_template)

    render json: { success: true, selected_images: selected_and_unselected_images[:selected_images], unselected_images: selected_and_unselected_images[:unselected_images] }
  end

  def add_image_to_image_pool
    authorize @message_template
    image_pool_manager = ImagePoolManager.new
    image_pool_manager.add_images(params[:image_id], @message_template)

    render json: { success: true }
  end

  def remove_image_from_image_pool
    authorize @message_template
    image_pool_manager = ImagePoolManager.new
    image_pool_manager.remove_image(params[:image_id], @message_template)

    render json: { success: true }
  end

  def import
    authorize MessageTemplate
    experiment = Experiment.find(params[:experiment_id])

    # Read Excel file from a URL
    excel_file_reader = ExcelFileReader.new
    excel_content = excel_file_reader.read(params[:url])

    # Import message templates
    message_template_importer = MessageTemplateImporter.new(excel_content, experiment.to_param)
    message_template_importer.import

    render json: { success: true, imported_count: excel_content.length - 1 }
  end

  private

  def set_message_template
    @message_template = MessageTemplate.find(params[:id])
  end
end
