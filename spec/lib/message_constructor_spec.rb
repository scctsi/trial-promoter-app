require 'rails_helper'

RSpec.describe MessageConstructor do
  before do
    @message_constructor = MessageConstructor.new
    @experiment = create(:experiment)
    @social_media_profile = create(:social_media_profile)
  end

  it 'does not try to replace the {url} variable if {url} is missing in the content of the message_template' do
    message_template = build(:message_template, content: 'This is a message template containing no variables')

    message = @message_constructor.construct(@experiment, message_template, :facebook, :ad, @social_media_profile)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing no variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
  end
  
  it 'constructs a message and replaces the {url} variable with the value of promoted_website_url in the message template' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables')

    message = @message_constructor.construct(@experiment, message_template, :facebook, :ad, @social_media_profile)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
  end
  
  it 'sets a date and time for the message' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables')

    message = @message_constructor.construct(@experiment, message_template, :facebook, :ad, @social_media_profile, DateTime.new(2017, 1, 1), DateTime.new(2017, 1, 1, 1, 30, 0))

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
    expect(message.scheduled_date_time).to eq(DateTime.new(2017, 1, 1, 1, 30, 0))
  end
  
  it 'appends a random hashtag from an array of hashtags to the message content' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables', hashtags: ['#hashtag1', '#hashtag2', '#hashtag3'])

    message = @message_constructor.construct(@experiment, message_template, :facebook, :ad, @social_media_profile, DateTime.new(2017, 1, 1), DateTime.new(2017, 1, 1, 1, 30, 0), ['#hashtag1,#hashtag2,#hashtag3'])

    expect(message.valid?).to be true
    expect(message.content).to include("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
    expect(message.scheduled_date_time).to eq(DateTime.new(2017, 1, 1, 1, 30, 0))
    expect(message_template.hashtags.any? {|hashtag| message.content.include?(hashtag)}).to be true
  end

  it 'appends a random hashtag from the fittable hashtags to the contents of a Twitter message' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables', hashtags: ['#hashtag1', '#hashtag2', '#hashtag3'])

    allow(MessageConstructor).to receive(:fittable_hashtags).and_return(['#hashtag1', '#hashtag2', '#hashtag3'])
    message = @message_constructor.construct(@experiment, message_template, :twitter, :ad, @social_media_profile, DateTime.new(2017, 1, 1), DateTime.new(2017, 1, 1, 1, 30, 0), ['#hashtag1,#hashtag2,#hashtag3'])

    expect(message.valid?).to be true
    expect(message.content).to include("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :twitter
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
    expect(message.scheduled_date_time).to eq(DateTime.new(2017, 1, 1, 1, 30, 0))
    expect(MessageConstructor.fittable_hashtags(message.content, message_template.hashtags).any? {|hashtag| message.content.include?(hashtag)}).to be true
  end

  it 'does not append a hashtag if there are no suitable hashtags that can be appended to the contents of a Twitter message' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables', hashtags: ['#hashtag1', '#hashtag2', '#hashtag3'])

    allow(MessageConstructor).to receive(:fittable_hashtags).and_return([])
    message = @message_constructor.construct(@experiment, message_template, :twitter, :ad, @social_media_profile, DateTime.new(2017, 1, 1), DateTime.new(2017, 1, 1, 1, 30, 0), ['#hashtag1,#hashtag2,#hashtag3'])

    expect(message.valid?).to be true
    expect(message.content).to include("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :twitter
    expect(message.medium).to be :ad
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
    expect(message.social_media_profile).to eq(@social_media_profile)
    expect(message.scheduled_date_time).to eq(DateTime.new(2017, 1, 1, 1, 30, 0))
  end

  describe 'appending a random hashtag for a Twitter message' do
    before do
      @hashtags = ['#short', '#long-hashtag', '#longest-hashtag']
    end
    
    it 'returns an empty array of fittable hashtags and all the hashtags for unfittable hashtags if no hashtag can be appended to some content' do
      content = 'A' * 141
      
      fittable_hashtags = MessageConstructor.fittable_hashtags(content, @hashtags)
      unfittable_hashtags = MessageConstructor.unfittable_hashtags(content, @hashtags)
      
      expect(fittable_hashtags).to eq([])
      expect(unfittable_hashtags).to eq(@hashtags)
    end

    it 'returns an empty array of fittable hashtags and all the hashtags for unfittable hashtags if no hashtag can be appended to some content (which includes a URL)' do
      content = "#{'A' * 118}{url}"
      
      fittable_hashtags = MessageConstructor.fittable_hashtags(content, @hashtags)
      unfittable_hashtags = MessageConstructor.unfittable_hashtags(content, @hashtags)
      
      expect(fittable_hashtags).to eq([])
      expect(unfittable_hashtags).to eq(@hashtags)
    end

    it 'returns the single hashtag for fittable hashtags and an empty array for unfittable hashtags if the single hashtag can be appended to some content (which includes a URL)' do
      @hashtags = ['#short']
      content = 'A' * (117 - @hashtags[0].length) + "{url}"
      
      fittable_hashtags = MessageConstructor.fittable_hashtags(content, @hashtags)
      unfittable_hashtags = MessageConstructor.unfittable_hashtags(content, @hashtags)
      
      expect(fittable_hashtags).to eq([@hashtags[0]])
      expect(unfittable_hashtags).to eq([])
    end

    it 'returns the only hashtags that are fittable and the list of the other hashtags as unfittable hashtags when only a few hashtags can be appended to some content (which includes a URL)' do
      content = 'A' * (117 - @hashtags[1].length) + "{url}"
      
      fittable_hashtags = MessageConstructor.fittable_hashtags(content, @hashtags)
      unfittable_hashtags = MessageConstructor.unfittable_hashtags(content, @hashtags)
      
      expect(fittable_hashtags).to eq([@hashtags[0], @hashtags[1]])
      expect(unfittable_hashtags).to eq([@hashtags[2]])
    end

    it 'returns all hashtags if every hashtag is fittable and an empty array for unfittable hashtags when all the hashtags can be appended to some content (which includes a URL)' do
      content = 'A' * (117 - @hashtags[2].length) + "{url}"
      
      fittable_hashtags = MessageConstructor.fittable_hashtags(content, @hashtags)
      unfittable_hashtags = MessageConstructor.unfittable_hashtags(content, @hashtags)
      
      expect(fittable_hashtags).to eq([@hashtags[0], @hashtags[1], @hashtags[2]])
      expect(unfittable_hashtags).to eq([])
    end
  end
end