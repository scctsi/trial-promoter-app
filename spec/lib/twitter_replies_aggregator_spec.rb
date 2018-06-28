require 'rails_helper'

RSpec.describe TwitterRepliesAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    experiment = build(:experiment)
    experiment.set_twitter_keys(secrets['twitter']['consumer_key'], secrets['twitter']['consumer_secret'], secrets['twitter']['access_token'], secrets['twitter']['access_token_secret'])
    @twitter_replies_aggregator = TwitterRepliesAggregator.new(experiment)
    @messages = create_list(:message, 3, message_generating: experiment)
    @messages[0].social_network_id = '611552752393654272'
    @messages[1].social_network_id = '562382154114408448'
    @messages[2].social_network_id = '522776562618224640'
    @messages.each{ |message| message.save }
    @messages[0].buffer_update = create(:buffer_update, published_text: "Learn more about our #clinicaltrial at @KeckMedUSC #USCNorris evaluating a potential #coloncancer treatment.")
    @messages[1].buffer_update = create(:buffer_update, published_text: "Join us tomorrow at 5pm to learn how @yueliao uses #Crowdfunding to support her research project. More details: http://bit.ly/1LFADeK")
    @messages[2].buffer_update = create(:buffer_update, published_text: "SC CTSI Matches Scientists with Community Mentors to Boost Success of Community-Engaged Research http://buff.ly/1rv49WM  cc @ncats_nih_gov")
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the name of an account' do
      VCR.use_cassette 'twitter_replies_aggregator/get_account_name' do
        account_name = @twitter_replies_aggregator.get_account_name('SoCalCTSI')
        expect(account_name).to eq("SoCal CTSI")
      end
    end
    
    it 'gets all the tweets' do
      VCR.use_cassette 'twitter_replies_aggregator/get_all_tweets' do
        tweets = @twitter_replies_aggregator.get_all_tweets('SoCalCTSI')

        expect(tweets.count).to eq(364)
      end
    end
    
    it 'gets a tweet given the tweet id' do
      VCR.use_cassette 'twitter_replies_aggregator/get_tweet' do
        tweet_id = '522776562618224640'
        
        tweet = @twitter_replies_aggregator.get_tweet(tweet_id)
      
        expect(tweet.text).to eq("SC CTSI Matches Scientists with Community Mentors to Boost Success of Community-Engaged Research http://t.co/vkUvF7cLh4 cc @ncats_nih_gov")
        expect(tweet.user.name).to eq("SoCal CTSI")
      end
    end
    
    it 'gets the comments for all tweets' do
      VCR.use_cassette 'twitter_replies_aggregator/get_comments' do
        comments = @twitter_replies_aggregator.get_comments

        expect(comments.count).to eq(98)
      
        expect(@messages[1].comments.count).to eq(1)
        expect(@messages[1].comments[0].message.social_network_id).to eq("562382154114408448")
        expect(@messages[1].comments[0].comment_text).to eq("Join @SoCalCTSI TODAY at 5pm to learn how @yueliao uses #Crowdfunding to support her research project. More details: http://t.co/C2Kdyyh0Cy")
        expect(@messages[2].comments[0].message.social_network_id).to eq("522776562618224640")
        expect(@messages[2].comments[0].comment_text).to eq("MT @SoCalCTSI matches #Scientists w/ #Community Mentors for #Community-Engaged #Research http://t.co/KBCImGm2Sx @ncats_nih_gov #CTSA #CBPR")
      end
    end
  end
end