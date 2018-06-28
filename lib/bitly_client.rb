class BitlyClient
  def initialize(experiment)
    Bitly.use_api_version_3

    Bitly.configure do |config|
      config.access_token = experiment.settings(:bitly).api_key
    end
  end

  def shorten(url)
    Bitly.client.shorten(url).short_url
  end
  
  def expand(bitly_url)
    Bitly.client.expand(bitly_url).long_url
  end
end