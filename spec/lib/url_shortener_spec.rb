require 'rails_helper'

RSpec.describe UrlShortener do
  before do
    @url_shortener = UrlShortener.new
  end

  it 'shortens a URL using bitly.com' do
    VCR.use_cassette('url_shortener/shorten') do
      shortened_url = @url_shortener.shorten('http://www.sc-ctsi.org')

      expect(shortened_url).to match(/http:\/\/bit.ly\/[A-Za-z0-9]{7}/)
    end
  end

  it 'expands a bitly.com shortened URL' do
    shortened_url = ''

    VCR.use_cassette('url_shortener/shorten') do
      shortened_url = @url_shortener.shorten('http://www.sc-ctsi.org')
    end

    VCR.use_cassette('url_shortener/expand') do
      expanded_url = @url_shortener.expand(shortened_url)

      expect(expanded_url).to eq('http://www.sc-ctsi.org/')
    end
  end

  # it 'shortens and expands a URL using bitly.com while preserving the UTM tracking fragment' do
  #   VCR.use_cassette('url_shortener/preserve_utm_tracking_fragment') do
  #     url = FactoryGirl.build(:url_with_utm_parameter_set)
  #
  #     shortened_url = @url_shortener.shorten(url.tracking_url)
  #     expanded_url = @url_shortener.expand(shortened_url)
  #
  #     expect(expanded_url).to eq(url.tracking_url)
  #   end
  # end
end
