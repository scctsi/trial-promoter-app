class BitlyClient
  def initialize
    Bitly.use_api_version_3

    Bitly.configure do |config|
      config.access_token = Setting[:bitly_access_token]
    end
  end

  def shorten(url)
    Bitly.client.shorten(url).short_url
  end
  
  def expand(bitly_url)
    Bitly.client.expand(bitly_url).long_url
  end
end