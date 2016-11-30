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
  
  def import
    experiment = Experiment.find(params[:experiment_id])

    # Read CSV file from a URL
    csv_file_reader = CsvFileReader.new
    parsed_csv_content = csv_file_reader.read(params[:url])
    
    # Import message templates
    importer = Importer.new
    importer.import(Website, parsed_csv_content, experiment.to_param)

    render json: { success: true, imported_count: parsed_csv_content.length - 1 }
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

