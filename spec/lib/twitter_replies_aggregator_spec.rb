require 'rails_helper'

RSpec.describe TwitterRepliesAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter).and_return(secrets['twitter'])
    @twitter_replies_aggregator = TwitterRepliesAggregator.new
    @messages = create_list(:message, 3)
    @messages[2].social_network_id = '931641729844789249'
    @messages[1].social_network_id = '860207525777559552'
    @messages.each{|message| message.save }
    @messages[0].buffer_update = create(:buffer_update, published_text: "Every day in the US 700+ youth become daily smokers. Nicotine is highly addictive. https://t.co/IyOA8GwASQ #tobacco https://t.co/81U9DrHpU0")
    @messages[1].buffer_update = create(:buffer_update, published_text: "Polonium-210 is a chemical in nuclear reactors. It’s also found in #cigarette smoke. https://t.co/y9vTJ05EVU https://t.co/PWhxTazzzs")
    @messages[2].buffer_update = create(:buffer_update, published_text: "location, location, location!")
    VCR.use_cassette 'twitter_replies_aggregator/test_setup' do
      @handle = @twitter_replies_aggregator.get_account('BeFreeOfTobacco')
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    
    it 'gets an account handle' do
      expect(@handle).to eq("BeFreeOfTobacco")
    end
    
    it 'gets all the tweets' do
      VCR.use_cassette 'twitter_replies_aggregator/get_all_tweets_for_a_handle' do
        tweets = @twitter_replies_aggregator.get_all_tweets_for_a_handle('BeFreeOfTobacco')

        expect(tweets.count).to eq(280)
      end
    end
    
    it 'gets the parent tweet for a comment' do
      VCR.use_cassette 'twitter_replies_aggregator/status' do
        parent_tweet_id = '931668280883871744'
        
        tweet = @twitter_replies_aggregator.get_parent_tweet_object(parent_tweet_id)
      
        expect(tweet.text).to eq("this is a test reply.")
        expect(tweet.user.name).to eq("BeFreeOfTobacco")
      end
    end
    
    it 'gets the comments for all tweets' do
      VCR.use_cassette 'twitter_replies_aggregator/get_comments' do
        comments = @twitter_replies_aggregator.get_comments

        expect(comments.count).to eq(6)
        expect(comments[0]['comment_text']).to eq("@BeFreeOfTobacco so many replies")
        expect(comments[0]['parent_tweet_id']).to eq("931668280883871744")
        expect(comments[0].message.social_network_id).to eq("931641729844789249")
        expect(comments[0].message.buffer_update.published_text).to eq("location, location, location!")
        expect(comments[4]['comment_text']).to eq("@BeFreeOfTobacco @SmokersMatch LOL, doubtful")
        expect(comments[4]['parent_tweet_id']).to eq("864963744425750531")
        expect(comments[4].message.social_network_id).to eq("860207525777559552")
        expect(comments[4].message.buffer_update.published_text).to eq("Polonium-210 is a chemical in nuclear reactors. It’s also found in #cigarette smoke. https://t.co/y9vTJ05EVU https://t.co/PWhxTazzzs")
        expect(comments[5]['comment_text']).to eq("@BeFreeOfTobacco https://t.co/zbPl4ZFCg3")
        expect(comments[5]['parent_tweet_id']).to eq("860207525777559552")
        expect(comments[5].message.social_network_id).to eq("860207525777559552")
        expect(comments[5].message.buffer_update.published_text).to eq("Polonium-210 is a chemical in nuclear reactors. It’s also found in #cigarette smoke. https://t.co/y9vTJ05EVU https://t.co/PWhxTazzzs")
      
      end
    end
  end
end