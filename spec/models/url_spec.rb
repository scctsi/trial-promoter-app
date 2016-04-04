require 'rails_helper'

RSpec.describe Url do
  it { is_expected.to validate_presence_of :value }

  it 'always use PostRank::URI.clean to set a clean value' do
    allow(PostRank::URI).to receive(:clean).and_return('cleaned_url')
    url = Url.new

    url.value = 'http://www.example.com:80/bar.html'

    expect(url.value).to eq('cleaned_url')
  end

  # it 'returns a tracking URL which appends the UTM tracking fragment' do
  #   url = FactoryGirl.build(:url_with_utm_parameter_set)
  #
  #   expect(url.tracking_url).to eq('http://www.sc-ctsi.org/?' + url.utm_parameter_set.tracking_fragment)
  # end
end

