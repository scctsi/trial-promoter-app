require 'rails_helper'

RSpec.describe CommentAggregator do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    @comment_aggregator = CommentAggregator.new
    @message = build(:message)
    @message.social_network_id = "980601328736431_1056074954522401"

    VCR.use_cassette 'comment_aggregator/test_setup' do
      pages = @comment_aggregator.get_user_object
      @page = pages.select{ |page| page["name"] == "B Free of Tobacco" }[0]
      @aggregated_comments = @comment_aggregator.get_comments(@message.social_network_id, @message)
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the page B Free Of Tobacco' do

      expect(@page).not_to be_nil
      expect(@page["name"]).to eq("B Free of Tobacco")
    end

    it 'gets the comments associated with a given message' do
      expect(@message.comments.count).to eq(22)
    end

    it 'saves the comments associated with a given message' do
      @message.reload

      expect(@message.comments[0].comment_text).to eq( "Cyanide is in apple seeds to lol")
    end

    it 'only saves comments once' do
      VCR.use_cassette 'comment_aggregator/get_comments_once' do
        @comment_aggregator.get_comments(@message.social_network_id, @message)
        @comment_aggregator.get_comments(@message.social_network_id, @message)

        @message.reload

        expect(@message.comments.count).to eq(22)
      end
    end
  end
end