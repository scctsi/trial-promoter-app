class WebsitesController < ApplicationController
  before_action :set_website, only: [:edit, :update]

  def index
    @websites = Website.all
  end

  def new
    @website = Website.new
  end

  def edit
  end

  def create
    @website = Website.new(website_params)

    if @website.save
      redirect_to websites_url
    else
      render :new
    end
  end

  def update
    if @website.update(website_params)
      redirect_to websites_url
    else
      render :edit
    end
  end

  private

  def set_website
    @website = Website.find(params[:id])
  end

  def website_params
    # TODO: Unit test this
    params[:website].permit(:name, :url)
  end
end

