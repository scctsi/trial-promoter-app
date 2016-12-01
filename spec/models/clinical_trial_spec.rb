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
#  hashtags         :text
#

require 'rails_helper'

describe ClinicalTrial do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :pi_first_name }
  it { is_expected.to validate_presence_of :pi_last_name }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :disease }

  it { is_expected.to have_many(:messages) }
  
  it 'is taggable with a single tag' do
    clinical_trial = create(:clinical_trial)
    
    clinical_trial.tag_list.add('experiment')
    clinical_trial.save
    clinical_trial.reload
    
    expect(clinical_trial.tags.count).to eq(1)
    expect(clinical_trial.tags[0].name).to eq('experiment')
  end
  
  it 'is taggable with multiple tags (some of them multi-word tags)' do
    clinical_trial = create(:clinical_trial)
    
    clinical_trial.tag_list.add('experiment', 'rare disease')
    clinical_trial.save
    clinical_trial.reload

    expect(clinical_trial.tags.count).to eq(2)
    expect(clinical_trial.tags[0].name).to eq('experiment')
    expect(clinical_trial.tags[1].name).to eq('rare disease')
  end

#   it 'stores an array of hashtags' do
#     clinical_trial = ClinicalTrial.new(:title => 'Some title', :pi_name => 'John Doe', :url => "http://www.sc-ctsi.org", :nct_id => "NCT1234567", :initial_database_id => "1", :hashtags => ["#First", "#Second"])
#     clinical_trial.save

#     clinical_trial.reload

#     expect(clinical_trial.hashtags).to eq(["#First", "#Second"])
#   end
end
