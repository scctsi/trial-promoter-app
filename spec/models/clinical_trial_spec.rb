require 'rails_helper'

describe ClinicalTrial do
  it { should validate_presence_of :title }
  it { should validate_presence_of :pi_first_name }
  it { should validate_presence_of :pi_last_name }
  it { should validate_presence_of :url }
  it { should validate_presence_of :disease }
  it { should have_many(:messages) }

#   it 'stores an array of hashtags' do
#     clinical_trial = ClinicalTrial.new(:title => 'Some title', :pi_name => 'John Doe', :url => "http://www.sc-ctsi.org", :nct_id => "NCT1234567", :initial_database_id => "1", :hashtags => ["#First", "#Second"])
#     clinical_trial.save

#     clinical_trial.reload

#     expect(clinical_trial.hashtags).to eq(["#First", "#Second"])
#   end
end
