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
end