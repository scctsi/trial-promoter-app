class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:edit, :update]

  def index
    @campaigns = Campaign.all
  end

  def new
    @campaign = Campaign.new
  end

  def edit
  end

  def create
    @campaign = Campaign.new(campaign_params)

    if @campaign.save
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to root_url
    else
      render :edit
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    # TODO: Unit test this
    params[:campaign].permit(:name, :start_date, :end_date)
    # params[:campaign].permit(:name, :start_date, :end_date, {:clinical_trial_ids => []})
  end
end
