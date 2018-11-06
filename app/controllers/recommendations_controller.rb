class RecommendationsController < ApplicationController
  def get
    authorize(:recommendation, :get?)
  end
end