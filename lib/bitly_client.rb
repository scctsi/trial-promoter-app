class BitlyClient
  def shorten(url)
    Bitly.client.shorten(url)
  end
end