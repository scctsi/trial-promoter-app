require 'rails_helper'

RSpec.describe ImageImporter do
  before do
    @image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
    @original_filenames = ['filename1.ext', 'filename2.ext']
    @experiment = create(:experiment)
    @experiment_tag = @experiment.to_param
    @image_importer = ImageImporter.new([@image_urls, @original_filenames], @experiment_tag)
  end
  
  it 'defines a post_initialize method which sets the import_class and column_index_attribute_mapping attributes' do
    @image_importer.post_initialize
    expect(@image_importer.import_class).to eq(Image)
    expect(@image_importer.column_index_attribute_mapping).to eq({ 0 => 'url', 1 => 'original_filename', 2 => 'tag_list' })
  end
  
  it 'defines a pre_import method which deletes all the message templates associated with the experiment' do
    create_list(:image, 2, experiment_list: [@experiment.to_param])

    @image_importer.pre_import
    
    expect(Image.belonging_to(@experiment).count).to eq(0)
  end

  it 'defines a pre_import_prepare method which converts the image URLs and original filenames to parsable CSV content' do
    prepared_csv_content = @image_importer.pre_import_prepare([@image_urls, @original_filenames])
    
    expect(prepared_csv_content).not_to eq(@image_urls)
    expect(prepared_csv_content).to eq([[nil, nil], ["http://www.images.com/image1.png", "filename1.ext"], ["http://www.images.com/image2.png", "filename2.ext"]])
  end

  it 'successfully imports images' do
    @image_importer.import
    
    expect(Image.count).to eq(@image_urls.size)
    image = Image.first
    expect(image.url).to eq(@image_urls[0])
    expect(image.original_filename).to eq(@original_filenames[0])
    expect(image.experiment_list).to eq([@experiment_tag])
  end
end
