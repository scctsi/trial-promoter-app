require 'rails_helper'

RSpec.describe ImageImporter do
  before do
    @image_importer = ImageImporter.new
  end
  
  it 'has a predefined CSV file column index attribute mapping' do
    expect(ImageImporter::COLUMN_INDEX_ATTRIBUTE_MAPPING).to eq({ 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' })
  end

  it 'successfully imports images' do
    image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
    experiment_tag = '1-tcors'

    @image_importer.import(image_urls, experiment_tag)
    
    expect(Image.count).to eq(image_urls.size)
    image = Image.first
    expect(image.url).to eq(image_urls[0])
    expect(image.original_filename).to eq('N/A')
    expect(image.experiment_list).to eq([experiment_tag])
  end
end
