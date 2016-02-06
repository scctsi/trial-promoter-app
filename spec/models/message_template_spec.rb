require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platform }

  # it { is_expected.to have_many :messages }

#   it 'saves the content as a string' do
#     message_template = MessageTemplate.new(:initial_id => "1", :platform => "twitter", :message_type => "awareness", :content => 'Some content')

#     message_template.save
#     message_template.reload

#     expect(message_template.content).to eq('Some content')
#   end

#   it 'saves the content as an array (used for Google, YouTube ads)' do
#     message_template = MessageTemplate.new(:initial_id => "1", :platform => "twitter", :message_type => "awareness", :content => ['Headline', 'Description Line 1', 'Description Line 2'])

#     message_template.save
#     message_template.reload

#     expect(message_template.content).to eq(['Headline', 'Description Line 1', 'Description Line 2'])
#   end
end
