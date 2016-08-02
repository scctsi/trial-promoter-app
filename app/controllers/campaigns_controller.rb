class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.all
  end
  
  def new
    @campaign = Campaign.new
  end
  
  def create
    Campaign.create!(campaign_params)
    redirect_to root_url
  end

private 
  def campaign_params
    # TODO: Unit test this
    params[:campaign].permit(:name,:start_date, :end_date) 
  end
end
