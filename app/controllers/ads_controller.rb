class AdsController < ApplicationController
  def previews
    authorize(:ad, :previews?)
  end
  
  def specifications
    authorize(:ad, :specifications?)
  end
end