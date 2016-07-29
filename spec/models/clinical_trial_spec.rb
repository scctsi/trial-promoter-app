# == Schema Information
#
# Table name: clinical_trials
#
#  id               :integer          not null, primary key
#  title            :string(1000)
#  pi_first_name    :string
#  pi_last_name     :string
#  url              :string(2000)
#  nct_id           :string
#  disease          :string
#  last_promoted_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

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
