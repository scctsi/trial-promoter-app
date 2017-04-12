class AnalyticsFilesController < ApplicationController
  def update
    analytics_file = AnalyticsFile.find(params[:id])
    authorize analytics_file
    analytics_file.url = params[:url]
    analytics_file.save

    render json: { success: true, id: analytics_file.id }
  end
  
  def process_all_files
    authorize AnalyticsFile
    ProcessAnalyticsFilesJob.perform_later
    flash[:notice] = 'All analytics files have been submitted for processing.'
    redirect_to root_url
  end
end
