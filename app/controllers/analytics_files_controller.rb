class AnalyticsFilesController < ApplicationController
  def update
    analytics_file = AnalyticsFile.find(params[:id])
    authorize AnalyticsFile
    analytics_file.update(analytics_file_params)

    render json: { success: true, id: analytics_file.id }
  end

  private

  def analytics_file_params
    # TODO: Unit test this
    params[:analytics_file].permit(:url, :original_filename)
  end
end
