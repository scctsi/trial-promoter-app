# == Schema Information
#
# Table name: images
#
#  id                              :integer          not null, primary key
#  url                             :string(2000)
#  original_filename               :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  width                           :integer
#  height                          :integer
#  meets_instagram_ad_requirements :boolean
#  codes                           :text
#  duplicated_image_id             :integer
#

require 'rails_helper'

RSpec.describe Image do
  it { is_expected.to serialize(:codes).as(Hash) }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :original_filename }
  it { is_expected.to have_many :messages }
  it { is_expected.to have_many(:duplicates).class_name('Image') }
  it { is_expected.to belong_to(:duplicated_image).class_name('Image') }

  it 'determines the filename of the image from the URL' do
    image = build(:image)
    image.url = 'https://s3-us-west-1.amazonaws.com/scctsi-tp-production/1-tcors/images/wXAEtMzPTpGqfA3CVH2n_tfl-TFL56.jpg'
    
    expect(image.filename).to eq('wXAEtMzPTpGqfA3CVH2n_tfl-TFL56.jpg')
  end

  describe 'setting duplicates' do
    before do
      @images = create_list(:image, 4)
      @images.each.with_index do |image, index|
        @images[index].url = "https://s3-us-west-1.amazonaws.com/scctsi-tp-production/1-tcors/images/file#{index}.jpg"
        @images[index].save
      end
    end
    
    it 'sets the duplicate for an image given two filenames of duplicated images' do
      Image.set_duplicate('file0.jpg', 'file3.jpg')
      
      @images.each { |image| image.reload }
      expect(@images[0].duplicates.count).to eq(1)
      expect(@images[0].duplicates[0]).to eq(@images[3])
      expect(@images[0].duplicated_image).to be_nil
      expect(@images[3].duplicated_image).to eq(@images[0])
    end
    
    it 'does not set the duplicate when the duplicate image filename is incorrect or not present' do
      Image.set_duplicate('file0.jpg', 'unknown-file.jpg')
      
      @images.each { |image| image.reload }
      expect(@images[0].duplicates.count).to eq(0)
    end
    
    it 'does not set the duplicate when the duplicated image filename is incorrect or not present' do
      Image.set_duplicate('unknown-file.jpg', 'file3.jpg')
      
      @images.each { |image| image.reload }
    end

    it 'sets multiple duplicates for an image given multiple sets of filenames' do
      Image.set_duplicate('file0.jpg', 'file3.jpg')
      Image.set_duplicate('file0.jpg', 'file2.jpg')
      
      @images.each { |image| image.reload }
      expect(@images[0].duplicates.count).to eq(2)
      expect(@images[0].duplicates[0]).to eq(@images[3])
      expect(@images[0].duplicates[1]).to eq(@images[2])
      expect(@images[0].duplicated_image).to be_nil
      expect(@images[2].duplicated_image).to eq(@images[0])
      expect(@images[3].duplicated_image).to eq(@images[0])
    end
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

  it 'triggers a callback when an image is destroyed' do
    image = create(:image)
    allow(image).to receive(:delete_image_from_s3)

    image.destroy

    expect(image).to have_received(:delete_image_from_s3)
  end

  it 'asks S3 to delete the corresponding object during the before destroy callback' do
    image = create(:image)
    s3_client_double = double('s3_client')
    allow(s3_client_double).to receive(:delete)
    allow(s3_client_double).to receive(:bucket).and_return('bucket')
    allow(s3_client_double).to receive(:key).and_return('key')
    allow(S3Client).to receive(:new).and_return(s3_client_double)

    image.delete_image_from_s3

    expect(s3_client_double).to have_received(:delete).with('bucket', 'key')
  end
  
  it 'maps an array of codes to a hash with the correct key and value' do
    image = create(:image)
    codes = ["0:color","2:portrait"]
    
    image.map_codes(codes) 

    image.reload    
    expect(image.codes).to eq({"0" => "color", "2" => "portrait"}) 
  end 
end
 
