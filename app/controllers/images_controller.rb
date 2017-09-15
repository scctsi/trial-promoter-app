class ImagesController < ApplicationController
  def save_codes
    image = Image.find(params[:id])
    authorize image
    #codes needs to be a hash
    # image.codes = params[:codes]
    image.save
    if request.xhr?
      render 'shared/_image_codes.html.haml', layout: false, locals: { image: image }
    else
      redirect_to root_path
    end
  end
  
  def add
    authorize Image
    experiment = Experiment.find(params[:experiment_id])

    # Import images
    image_importer = ImageImporter.new([params[:image_urls], params[:original_filenames]], experiment.to_param, {delete_existing_images: false})
    image_importer.import

    render json: { success: true, imported_count: params[:image_urls].length }
  end

  def import
    authorize Image
    experiment = Experiment.find(params[:experiment_id])

    # Import images
    image_importer = ImageImporter.new([params[:image_urls], params[:original_filenames]], experiment.to_param)
    image_importer.import

    render json: { success: true, imported_count: params[:image_urls].length }
  end
  
  def check_validity_for_instagram_ads
    authorize Image
    CheckValidityForInstagramAdsJob.perform_later
    flash[:notice] = 'Images are being checked for validity in Instagram ads'
    redirect_to root_url
  end
end

