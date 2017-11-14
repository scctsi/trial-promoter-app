require 'rails_helper'

RSpec.describe FacebookCommentsAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @facebook_comments_aggregator = FacebookCommentsAggregator.new

    VCR.use_cassette 'facebook_comments_aggregator/test_setup' do
      pages = @facebook_comments_aggregator.get_user_object
      @page = pages.select{ |page| page["name"] == "B Free of Tobacco" }[0]
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the page B Free Of Tobacco' do

      expect(@page).not_to be_nil
      expect(@page["name"]).to eq("B Free of Tobacco")
    end
    
    it 'gets comments for an individual post' do
      VCR.use_cassette 'facebook_comments_aggregator/get_post_comments' do
      
        @facebook_comments_aggregator.get_post_comments(@page["id"])
      end
    end

    it 'saves comments to the matching message' do
      messages = []
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/2t2KVBd"))
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/7o3PALs"))
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/6nBSWg"))

      VCR.use_cassette 'facebook_comments_aggregator/get_comments' do
        @facebook_comments_aggregator.get_comments(@page["id"])
        
        expect(messages[0].comments.map(&:comment_text)).to include("how gross is that!!!!!")
      end
    end
  end
end