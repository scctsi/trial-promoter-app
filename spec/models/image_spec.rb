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
end
