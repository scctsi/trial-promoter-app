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
  it { is_expected.to have_many :messages }

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

  it 'calls a post delete callback when the image is destroyed' do
    image = create(:image)
    allow(image).to receive(:delete_image_from_s3)

    image.destroy

    expect(image).to have_received(:delete_image_from_s3)
  end

  it 'correctly calculates the S3 bucket name for an image' do
    image = create(:image, url: 'https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')

    expect(image.s3_bucket).to eq('scctsi-tp-development')
  end

  it 'correctly calculates the S3 key for an image' do
    image = create(:image, url: 'https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')

    expect(image.s3_key).to eq('13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')
  end

  it 'determines if an asset currently exists in S3' do
    image = create(:image, url: 'https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')
    s3_client = S3Client.new

    WebMock.allow_net_connect!
    VCR.turn_off!
    asset_exists = s3_client.asset_exists_in_s3?(image)
    VCR.turn_on!
    WebMock.disable_net_connect!

    expect(asset_exists).to be true
  end

  # it 'asks S3client to delete the object when the image is deleted' do
  #   image = create(:image)
  #   # image.destroy

  #   # expect(s3_client).to have_received(:delete).with(image.url)

  #   # # Write code to add an image to S3
  #   # S3.put('spec/test-image.png')
  #   # S3client.put('1-tcors/test-image.png', 'spec/test-image.png')
  #   # # Check to see if object exists on S3
  #   # S3client.exists?('1-tcors/test-image.png')

  #   # # Write code to delete the same image in S3
  #   # S3client.delete('1-tcors/test-image.png')
  #   # Image.delete_image_from_s3

  #   # # Check to see if object exists on S3
  #   # S3client.exists?('1-tcors/test-image.png')
  # end
end
