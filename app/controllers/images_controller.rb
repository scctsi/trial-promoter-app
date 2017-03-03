class ImagesController < ApplicationController
  def import
    authorize Image
    experiment = Experiment.find(params[:experiment_id])

    # Import images
    image_importer = ImageImporter.new([params[:image_urls], params[:original_filenames]], experiment.to_param)
    image_importer.import

    render json: { success: true, imported_count: params[:image_urls].length }
  end
  
  def tag_images
    authorize Image

    params[:image_ids].each do |image_id|
      image = Image.find(image_id)
      image.tag_list = params[:tags]
      image.save
    end

    render json: { success: true, tagged_count: params[:image_ids].length }
  end
end
