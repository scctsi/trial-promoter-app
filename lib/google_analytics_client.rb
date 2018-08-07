require 'google/apis/analytics_v3'

class GoogleAnalyticsClient
  DEFAULT_METRICS = %w(ga:users ga:sessions ga:sessionDuration ga:timeOnPage ga:avgSessionDuration ga:avgTimeOnPage ga:pageviews ga:exits)
  DEFAULT_DIMENSIONS = %w(ga:campaign ga:sourceMedium ga:adContent)

  attr_reader :profile_id, :scopes, :google_auth_json_file, :service

  def initialize(experiment, profile_id)
    @profile_id = profile_id
    @scopes = ['https://www.googleapis.com/auth/analytics.readonly']
    @google_auth_json_file = StringIO.new(experiment.settings(:google).auth_json_file)

    # Authenticate and create a service object
    Google::Apis::ClientOptions.default.application_name = 'Trial Promoter'
    Google::Apis::ClientOptions.default.application_version = '1.0.0'
    auth = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: @google_auth_json_file, scope: @scopes)
    @service = Google::Apis::AnalyticsV3::AnalyticsService.new
    @service.authorization = auth
  end
  
  def table_id
    "ga:#{profile_id}"
  end

  def get_data(start_date, end_date, metric_list = DEFAULT_METRICS, dimension_list = DEFAULT_DIMENSIONS)  
    metric_list = metric_list.join(",")
    dimension_list = dimension_list.join(",")
    @service.get_ga_data(table_id, start_date, end_date, metric_list, dimensions: dimension_list, max_results: 100000)
  end
end