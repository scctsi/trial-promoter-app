require 'rails_helper'

RSpec.describe UrlShortener do
  before do
    @url_shortener = UrlShortener.new
  end

  it 'shortens a URL using bitly.com' do
    WebMock.allow_net_connect!
       
    VCR.use_cassette('url_shortener/shorten') do
      shortened_url = @url_shortener.shorten('http://www.sc-ctsi.org')

      expect(shortened_url).to match(/http:\/\/bit.ly\/[A-Za-z0-9]{7}/)
    end
    
    WebMock.disable_net_connect!
  end

  it 'expands a bitly.com shortened URL' do
    WebMock.allow_net_connect!

    shortened_url = ''
    expanded_url = ''
    
    VCR.use_cassette('url_shortener/shorten') do
      shortened_url = @url_shortener.shorten('http://www.sc-ctsi.org')
    end
    VCR.use_cassette('url_shortener/expand') do
      expanded_url = @url_shortener.expand(shortened_url)
    end

    expect(expanded_url).to eq('http://www.sc-ctsi.org/')

    WebMock.disable_net_connect!
  end
end