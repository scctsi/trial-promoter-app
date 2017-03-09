require 'rails_helper'

RSpec.describe MessageConstructor do
  before do
    @message_constructor = MessageConstructor.new
    @experiment = create(:experiment)
  end
  
  it 'replaces the variables in the message template with the value of the attributes of the supplied website' do
    message_template = MessageTemplate.new(content: 'This is a message template containing {url} variables')

    message = @message_constructor.construct(@experiment, message_template, 'http://url.com', :facebook)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing http://url.com variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promoted_website_url).to eq('http://url.com')
    expect(message.message_generating).to eq(@experiment)
    expect(message.platform).to eq :facebook
    expect(message.medium).to be :organic
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
  end
  
  it 'constructs a message with a medium' do
    message_template = MessageTemplate.new(content: 'This is a message template containing {name} and {url} variables')

    message = @message_constructor.construct(@experiment, message_template, 'http://url.com', :twitter, :ad)

    expect(message.platform).to be :twitter
    expect(message.medium).to be :ad
  end
end