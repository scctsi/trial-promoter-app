# require 'rails_helper'
#
# RSpec.describe UtmParameterSet do
#   before do
#     @utm_parameter_set = UtmParameterSet.new
#   end
#
#   it 'has an attr_accessor for source' do
#     expect(@utm_parameter_set).to respond_to('source')
#     expect(@utm_parameter_set).to respond_to('source=')
#   end
#
#   it 'has an attr_accessor for medium' do
#     expect(@utm_parameter_set).to respond_to('medium')
#     expect(@utm_parameter_set).to respond_to('medium=')
#   end
#
#   it 'has an attr_accessor for campaign' do
#     expect(@utm_parameter_set).to respond_to('campaign')
#     expect(@utm_parameter_set).to respond_to('campaign=')
#   end
# end

# require 'rails_helper'
#
# RSpec.describe UtmParameterSet do
#   it { is_expected.to validate_presence_of :source }
#   it { is_expected.to validate_presence_of :medium }
#   it { is_expected.to validate_presence_of :campaign }
#
#   before do
#     @utm_parameter_set = FactoryGirl.build(:utm_parameter_set)
#   end
#
#   it 'only allows hyphens and alphanumeric characters for the source' do
#     @utm_parameter_set.source = 'twitter ad'
#     expect(@utm_parameter_set).to_not be_valid
#
#     @utm_parameter_set.source = 'twitter_ad'
#     expect(@utm_parameter_set).to_not be_valid
#   end
#
#   it 'only allows hyphens and alphanumeric characters for the medium' do
#     @utm_parameter_set.medium = 'public feed'
#     expect(@utm_parameter_set).to_not be_valid
#
#     @utm_parameter_set.medium = 'public_feed'
#     expect(@utm_parameter_set).to_not be_valid
#   end
#
#   it 'only allows hyphens and alphanumeric characters for the campaign' do
#     @utm_parameter_set.campaign = 'trial promoter'
#     expect(@utm_parameter_set).to_not be_valid
#
#     @utm_parameter_set.campaign = 'trial_promoter'
#     expect(@utm_parameter_set).to_not be_valid
#   end
#
#   it 'creates a UTM tracking fragment' do
#     expect(@utm_parameter_set.tracking_fragment).to eq("utm_source=#{@utm_parameter_set.source}&utm_medium=#{@utm_parameter_set.medium}&utm_campaign=#{@utm_parameter_set.campaign}")
#   end
# end
