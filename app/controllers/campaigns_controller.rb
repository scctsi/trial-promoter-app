class CampaignsController < ApplicationController
  def index
  end
  
  def new
    @campaign = Campaign.new
  end
end
