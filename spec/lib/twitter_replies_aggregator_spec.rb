require 'rails_helper'

RSpec.describe TwitterRepliesAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter).and_return(secrets['twitter'])
    @twitter_replies_aggregator = TwitterRepliesAggregator.new
    @message = build(:message)
  #   @message.social_network_id = "980601328736431_1056074954522401"

    VCR.use_cassette 'twitter_replies_aggregator/test_setup' do
      @handle = @twitter_replies_aggregator.get_account('BeFreeOfTobacco')
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets an account handle' do
      
      expect(@handle).to eq("BeFreeOfTobacco")
    end
  end
  
  it 'gets the timeline of the main account' do
    VCR.use_cassette 'twitter_replies_aggregator/get_tweets' do
        tweets = @twitter_replies_aggregator.get_tweets
        file_lines_count_first = CSV.read("twitter_replies.csv").count
        @twitter_replies_aggregator.get_tweets
        file_lines_count_second = CSV.read("twitter_replies.csv").count

        expect(tweets).to eq([])
        expect(file_lines_count_first).to eq(0)
        expect(file_lines_count_first).to eq(file_lines_count_second)
    end
  end
end