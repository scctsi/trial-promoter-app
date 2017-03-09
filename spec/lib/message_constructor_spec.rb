require 'rails_helper'

RSpec.describe MessageConstructor do
  before do
    @message_constructor = MessageConstructor.new
    @experiment = create(:experiment)
  end

  it 'does not try to replace the {url} variable if {url} is missing in the content of the message_template' do
    message_template = build(:message_template, content: 'This is a message template containing no variables')

    message = @message_constructor.construct(@experiment, message_template, :facebook)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing no variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :organic
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
  end
  
  it 'constructs a message and replaces the {url} variable with the value of promoted_website_url in the message template' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables')

    message = @message_constructor.construct(@experiment, message_template, :facebook)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing #{message_template.promoted_website_url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq(message_template.promoted_website_url)
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :organic
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
  end
  
  it 'constructs a message with a specific medium' do
    message_template = build(:message_template, content: 'This is a message template containing {url} variables')

    message = @message_constructor.construct(@experiment, message_template, :twitter, :ad)

    expect(message.platform).to be :twitter
    expect(message.medium).to be :ad
  end
end