# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(1000)
#  url        :string(2000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Website do
  it { is_expected.to validate_presence_of :url }

  it { is_expected.to have_many(:messages) }

  it 'is taggable with a single tag' do
    website = create(:website)
    
    website.tag_list.add('experiment')
    website.save
    website.reload
    
    expect(website.tags.count).to eq(1)
    expect(website.tags[0].name).to eq('experiment')
  end
  
  it 'is taggable with multiple tags (some of them multi-word tags)' do
    website = create(:website)
    
    website.tag_list.add('experiment', 'text heavy')
    website.save
    website.reload

    expect(website.tags.count).to eq(2)
    expect(website.tags[0].name).to eq('experiment')
    expect(website.tags[1].name).to eq('text heavy')
  end
  
  it 'is taggable on experiments with a single tag' do
    website = create(:website)
    
    website.experiment_list.add('tcors')
    website.save
    website.reload
    
    expect(website.experiments.count).to eq(1)
    expect(website.experiments[0].name).to eq('tcors')
  end
  
  it 'is taggable on experiments with multiple tags (some of them multi-word tags)' do
    website = create(:website)
    
    website.experiment_list.add('tcors', 'tcors 2')
    website.save
    website.reload
    
    expect(website.experiments.count).to eq(2)
    expect(website.experiments[0].name).to eq('tcors')
    expect(website.experiments[1].name).to eq('tcors 2')
  end
end
