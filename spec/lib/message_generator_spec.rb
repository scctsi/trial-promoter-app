require 'rails_helper'

RSpec.describe MessageGenerator do
  before do
    @message_generator = MessageGenerator.new
  end
  
  it 'replaces the variables in the message template with the value of the attributes of the supplied clinical trial' do
    clinical_trial = ClinicalTrial.new(pi_first_name: 'First', pi_last_name: 'Last', disease: 'Disease', url: 'http://www.url.com')
    message_template = MessageTemplate.new(content: 'This is a message template containing {pi_first_name}, {pi_last_name}, { Disease}, {URL} variables')

    message = @message_generator.generate(message_template, clinical_trial)

    expect(message.content).to eq("This is a message template containing #{clinical_trial.pi_first_name}, #{clinical_trial.pi_last_name}, #{clinical_trial.disease}, #{clinical_trial.url} variables")
  end
  
  it 'replaces the variables in the message template with the value of the attributes of the supplied website' do
    website = Website.new(title: 'Title', url: 'http://www.url.com')
    message_template = MessageTemplate.new(content: 'This is a message template containing {title} and {url} variables')

    message = @message_generator.generate(message_template, website)

    expect(message.content).to eq("This is a message template containing #{website.title} and #{website.url} variables")
  end
end