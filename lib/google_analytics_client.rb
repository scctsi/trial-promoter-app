require 'google/apis/analytics_v3'

class GoogleAnalyticsClient
  attr_reader :profile_id, :scopes, :google_auth_json_file, :service

  def initialize(profile_id)
    @profile_id = profile_id
    @scopes = ['https://www.googleapis.com/auth/analytics.readonly']
    @google_auth_json_file = StringIO.new(Setting[:google_auth_json_file])
    auth = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: @google_auth_json_file, scope: @scopes)
    @service = Google::Apis::AnalyticsV3::AnalyticsService.new
    @service.authorization = auth
    Google::Apis::ClientOptions.default.application_name = 'Trial Promoter'
    Google::Apis::ClientOptions.default.application_version = '1.0.0'
  end
  
  def table_id
    "ga:#{profile_id}"
  end
end