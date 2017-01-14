class ImagesController < ApplicationController
  def create
    authorize Image
    image = Image.create!(image_params)

    render json: { success: true, id: image.id }
  end

  def import
    authorize Image
    experiment = Experiment.find(params[:experiment_id])

    # Import images
    image_importer = ImageImporter.new(params[:image_urls], experiment.to_param)
    image_importer.import

    render json: { success: true, imported_count: params[:image_urls].length }
  end

  private

  def image_params
    # TODO: Unit test this
    params[:image].permit(:url, :original_filename)
  end
end
