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
    

    it 'getting all comments for a page and matching them to the correct message via published text' do
      messages = []
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/2t2KVBd"))
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/7o3PALs"))
      messages << create(:message, buffer_update: create(:buffer_update, published_text: "Hydrogen cyanide is found in rat poison. It’s also in #cigarette smoke. http://bit.ly/6nBSWg"))

      VCR.use_cassette 'facebook_comments_aggregator/get_comments' do
        @facebook_comments_aggregator.get_comments(@page["id"])
        
        expect(messages[0].comments.map(&:comment_text)).to include("how gross is that!!!!!")
      end
    end
  
    it 'gets 25 posts (pagination limit) for a facebook page' do
      VCR.use_cassette 'facebook_comments_aggregator/get_paginated_posts' do
        posts = @facebook_comments_aggregator.get_paginated_posts(@page["id"])
        expect(posts[0]["message"]).to include("100 million+ US non-smokers are exposed to toxic secondhand smoke. Protect your loved ones by living #tobaccofree. http:\/\/bit.ly\/2trX166")
        expect(posts.count).to eq(25)
      end
    end
    
    it 'gets comments for an individual post' do
      VCR.use_cassette 'facebook_comments_aggregator/get_post_comments' do
        posts = @facebook_comments_aggregator.get_paginated_posts(@page["id"])
        @facebook_comments_aggregator.get_post_comments(posts[5]["id"], posts[5]["message"])
        
        expect(Comment.count).to eq(3)
      end
    end
  end
end