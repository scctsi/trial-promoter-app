class PerspectiveClient
  include HTTParty

  def initialize
    perspective_key = Setting[:google_perspective_access_key]
  end

end