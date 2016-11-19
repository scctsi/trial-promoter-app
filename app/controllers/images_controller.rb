class ImagesController < ApplicationController
  def create
    image = Image.create!(image_params)
    
    render json: { success: true, id: image.id }
  end
  
  private
  
  def image_params
    # TODO: Unit test this
    params[:image].permit(:url, :original_filename)
  end
end
