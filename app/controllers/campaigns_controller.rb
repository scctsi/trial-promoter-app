class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.all
  end
  
  def new
    @campaign = Campaign.new
  end
end
