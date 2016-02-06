require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of(:content) }
  
  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }

#   it 'saves the content as a string' do
#     message = Message.new(:campaign => 'trial-promoter', :medium => 'paid', :content => 'Some content')

#     message.save
#     message.reload

#     expect(message.content).to eq('Some content')
#   end

#   it 'saves the content as an array (used for Google, YouTube ads)' do
#     message = Message.new(:campaign => 'trial-promoter', :medium => 'paid', :content => ['Headline', 'Description Line 1', 'Description Line 2'])

#     message.save
#     message.reload

#     expect(message.content).to eq(['Headline', 'Description Line 1', 'Description Line 2'])
#   end
end
