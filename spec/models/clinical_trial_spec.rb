require 'rails_helper'

describe ClinicalTrial do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:pi_first_name) }
  it { is_expected.to validate_presence_of(:pi_last_name) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:disease) }
  it { is_expected.to have_many(:messages) }

#   it 'stores an array of hashtags' do
#     clinical_trial = ClinicalTrial.new(:title => 'Some title', :pi_name => 'John Doe', :url => "http://www.sc-ctsi.org", :nct_id => "NCT1234567", :initial_database_id => "1", :hashtags => ["#First", "#Second"])
#     clinical_trial.save

#     clinical_trial.reload

#     expect(clinical_trial.hashtags).to eq(["#First", "#Second"])
#   end
end
