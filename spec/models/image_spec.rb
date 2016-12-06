# == Schema Information
#
# Table name: images
#
#  id                :integer          not null, primary key
#  url               :string(2000)
#  original_filename :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe Image do
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :original_filename }

  it 'is taggable with a single tag' do
    image = create(:image)
    
    image.tag_list.add('smoking')
    image.save
    image.reload
    
    expect(image.tags.count).to eq(1)
    expect(image.tags[0].name).to eq('smoking')
  end
  
  it 'is taggable with multiple tags (some of them multi-word tags)' do
    image = create(:image)
    
    image.tag_list.add('smoking', 'woman')
    image.save
    image.reload
    
    expect(image.tags.count).to eq(2)
    expect(image.tags[0].name).to eq('smoking')
    expect(image.tags[1].name).to eq('woman')
  end
  
  it 'is taggable on experiments with a single tag' do
    image = create(:image)
    
    image.experiment_list.add('tcors')
    image.save
    image.reload
    
    expect(image.experiments.count).to eq(1)
    expect(image.experiments[0].name).to eq('tcors')
  end
  
  it 'is taggable on experiments with multiple tags (some of them multi-word tags)' do
    image = create(:image)
    
    image.experiment_list.add('tcors', 'tcors 2')
    image.save
    image.reload
    
    expect(image.experiments.count).to eq(2)
    expect(image.experiments[0].name).to eq('tcors')
    expect(image.experiments[1].name).to eq('tcors 2')
  end
  
  it 'has a scope for finding images that belong to an experiment' do
    experiments = create_list(:experiment, 3)
    images = create_list(:image, 3)
    images.each.with_index do |image, index| 
      image.experiment_list = experiments[index].to_param
      image.save
    end

    images_for_first_experiment = Image.belonging_to(experiments[0])
    
    expect(images_for_first_experiment.count).to eq(1)
    expect(images_for_first_experiment[0].experiment_list).to eq([experiments[0].to_param])
  end
end
