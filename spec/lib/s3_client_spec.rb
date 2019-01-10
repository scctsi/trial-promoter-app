require 'rails_helper'
require 'yaml'

RSpec.describe S3Client do
  describe "(development only tests)", :development_only_tests => true do
    before do
      experiment = build(:experiment)
      secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
      experiment.set_aws_key(secrets['aws_access_key_id'], secrets['aws_secret_access_key'])
      @s3_client = S3Client.new(experiment)
    end

    it 'correctly calculates the bucket name for a URL' do
      expect(@s3_client.bucket('https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')).to eq('scctsi-tp-development')
    end

    it 'correctly calculates the S3 key for a URL' do
      expect(@s3_client.key('https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')).to eq('13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')
    end

    it 'correctly calculates the S3 region for a URL' do
      expect(@s3_client.region('https://s3-us-west-1.amazonaws.com/scctsi-tp-development/13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')).to eq('us-west-1')
    end

    it 'determines if an asset currently exists in S3' do
      asset_exists = false

      VCR.use_cassette 's3_client/object_exists_in_s3?' do
        asset_exists = @s3_client.object_exists?('scctsi-tp-development','13-tcors/images/ywCyYa4LSXKtahc4Flgc_3-1-000.jpg')
      end

      expect(asset_exists).to be true
    end

    it 'deletes an asset from S3' do
      #TODO Create a VCR cassette for this 
      WebMock.allow_net_connect!
      VCR.turn_off!

      # Store fixtures/logo.png in S3
      File.open('spec/fixtures/logo.png', 'rb') do |file|
        @s3_client.put('scctsi-tp-development', 'object-key', file)
      end
      expect(@s3_client.object_exists?('scctsi-tp-development','object-key')).to be true

      # Run delete
      @s3_client.delete('scctsi-tp-development', 'object-key')
      expect(@s3_client.object_exists?('scctsi-tp-development','object-key')).to be false

      VCR.turn_on!
      WebMock.disable_net_connect!
    end
  end
end