class UrlShortener
  def shorten(url)
    Bitly.client.shorten(url).short_url
  end

  def expand(bitly_url)
    Bitly.client.expand(bitly_url).long_url
  end
end