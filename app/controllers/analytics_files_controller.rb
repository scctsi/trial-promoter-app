class AnalyticsFilesController < ApplicationController
  def update
    analytics_file = AnalyticsFile.find(params[:id])
    authorize AnalyticsFile
    analytics_file.url = params[:url]
    analytics_file.save

    render json: { success: true, id: analytics_file.id }
  end
end
