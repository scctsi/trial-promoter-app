require 'rails_helper'

RSpec.describe MessageConstructor do
  before do
    @message_constructor = MessageConstructor.new
    @experiment = create(:experiment)
  end
  
  it 'replaces the variables in the message template with the value of the attributes of the supplied clinical trial' do
    clinical_trial = ClinicalTrial.new(pi_first_name: 'First', pi_last_name: 'Last', disease: 'Disease', url: 'http://www.url.com')
    message_template = MessageTemplate.new(content: 'This is a message template containing {pi_first_name}, {pi_last_name}, { Disease}, {URL} variables')

    message = @message_constructor.construct(@experiment, message_template, clinical_trial)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing #{clinical_trial.pi_first_name}, #{clinical_trial.pi_last_name}, #{clinical_trial.disease}, #{clinical_trial.url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promotable).to eq(clinical_trial)
    expect(message.message_generating).to eq(@experiment)
    expect(message.medium).to eq :organic
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
  end
  
  it 'replaces the variables in the message template with the value of the attributes of the supplied website' do
    website = Website.new(name: 'Name', url: 'http://www.url.com')
    message_template = MessageTemplate.new(content: 'This is a message template containing {name} and {url} variables')

    message = @message_constructor.construct(@experiment, message_template, website)

    expect(message.valid?).to be true
    expect(message.content).to eq("This is a message template containing #{website.name} and #{website.url} variables")
    expect(message.message_template).to eq(message_template)
    expect(message.promotable).to eq(website)
    expect(message.message_generating).to eq(@experiment)
    expect(message.medium).to be :organic
    expect(message.image_present).to eq(:without)
    expect(message.image).to be_nil
  end
  
  it 'constructs a message with a medium' do
    website = Website.new(name: 'Name', url: 'http://www.url.com')
    message_template = MessageTemplate.new(content: 'This is a message template containing {name} and {url} variables')

    message = @message_constructor.construct(@experiment, message_template, website, :ad)

    expect(message.medium).to be :ad
  end
end