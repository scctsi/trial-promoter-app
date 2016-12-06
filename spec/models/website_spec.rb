# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  name       :string(1000)
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
  
  it 'has a scope for finding websites that belong to an experiment' do
    experiments = create_list(:experiment, 3)
    websites = create_list(:website, 3)
    websites.each.with_index do |website, index| 
      website.experiment_list = experiments[index].to_param
      website.save
    end

    websites_for_first_experiment = Website.belonging_to(experiments[0])
    
    expect(websites_for_first_experiment.count).to eq(1)
    expect(websites_for_first_experiment[0].experiment_list).to eq([experiments[0].to_param])
  end
end