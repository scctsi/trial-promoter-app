require 'rails_helper'
require 'yaml'

RSpec.describe BufferClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:buffer_access_token).and_return(secrets['buffer_access_token'])
    allow(BufferClient).to receive(:post).and_call_original
    allow(BufferClient).to receive(:get).and_call_original
    @message = build(:message)
    social_media_profile = build(:social_media_profile, buffer_id: '53275ff6c441ced7264e4ca5')
    @message.social_media_profile = social_media_profile
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'returns the body of the POST request for creating a Buffer update via the Buffer API' do
      post_request_body = BufferClient.post_request_body_for_create(@message)

      expect(post_request_body[:profile_ids]).to eq(@message.social_media_profile.buffer_id)
      expect(post_request_body[:text]).to eq(@message.content)
      expect(post_request_body[:shorten]).to eq(true)
      expect(post_request_body[:access_token]).to eq(Setting[:buffer_access_token])
    end

    it 'returns the body of the POST request when the message contains an image' do
      @message.image_present = :with
      @message.image = create(:image)
      @message.save
      post_request_body = BufferClient.post_request_body_for_create(@message)

      expect(post_request_body[:profile_ids]).to eq(@message.social_media_profile.buffer_id)
      expect(post_request_body[:text]).to eq(@message.content)
      expect(post_request_body[:shorten]).to eq(true)
      expect(post_request_body[:access_token]).to eq(Setting[:buffer_access_token])
      expect(post_request_body[:media]).to eq({"thumbnail": @message.image.url, "photo": @message.image.url})
    end

    it 'adds a scheduled_at key in the body of the POST request for a message that has a specifc scheduled date time' do
      @message.scheduled_date_time = DateTime.new(2000, 1, 1, 6, 30, 0)

      post_request_body = BufferClient.post_request_body_for_create(@message)

      expect(post_request_body[:scheduled_at]).to eq(@message.scheduled_date_time.to_s)
    end

    describe 'synchronizing the list of social profiles' do
      it 'uses the Buffer API to get an initial of social media profiles' do
        VCR.use_cassette 'buffer/get_social_media_profiles' do
          BufferClient.get_social_media_profiles
        end

        expect(BufferClient).to have_received(:get).with("https://api.bufferapp.com/1/profiles.json?access_token=#{Setting[:buffer_access_token]}")
        expect(SocialMediaProfile.count).to eq(7)
        social_media_profile = SocialMediaProfile.first
        expect(social_media_profile.platform).to eq(:facebook)
        expect(social_media_profile.service_id).to eq('864687273610386')
        expect(social_media_profile.service_type).to eq('page')
        expect(social_media_profile.service_username).to eq('Boosted-Staging USC Clinical Trials')
        expect(social_media_profile.buffer_id).to eq('55c11ce246042c5e7f8ae843')
      end

      it 'does not add a profile if it already exists (based on buffer_id being unique)' do
        SocialMediaProfile.create!(buffer_id: '55c11ce246042c5e7f8ae843', service_id: '1', service_username: 'user', platform: :twitter)

        VCR.use_cassette 'buffer/get_social_media_profiles' do
          BufferClient.get_social_media_profiles
        end

        social_media_profiles = SocialMediaProfile.all
        expect(social_media_profiles.count).to eq(7)
        # Are the buffer ids unique?
        buffer_ids = social_media_profiles.map(&:buffer_id)
        expect(buffer_ids.detect{ |buffer_id| buffer_ids.count(buffer_id) > 1 }).to be_nil
      end
    end

    it 'uses the Buffer API to create an update' do
      VCR.use_cassette 'buffer/create_update' do
        BufferClient.create_update(@message)
      end

      expect(BufferClient).to have_received(:post).with('https://api.bufferapp.com/1/updates/create.json', {:body => BufferClient.post_request_body_for_create(@message)})
      expect(@message.buffer_update).not_to be_nil
      # The response returned from Buffer contains a Buffer ID that we need to store in a newly created buffer_update
      expect(@message.buffer_update.buffer_id).not_to be_blank
      # The message and the new Buffer update should be persisted
      expect(@message.persisted?).to be_truthy
      expect(@message.buffer_update.persisted?).to be_truthy
    end

    it 'uses the Buffer API to get an update to the status (pending, sent) of a BufferUpdate and simultaneously updates the metrics for the corresponding message' do
      buffer_id = '55f8a111b762b0cf06d79116'
      @message.buffer_update = BufferUpdate.new(:buffer_id => buffer_id)

      VCR.use_cassette 'buffer/get_update' do
        BufferClient.get_update(@message)
      end

      expect(BufferClient).to have_received(:get).with("https://api.bufferapp.com/1/updates/#{buffer_id}.json?access_token=#{Setting[:buffer_access_token]}")
      expect(@message.buffer_update.status).to eq(:sent)
      # The sent_from_date_time should be equal to the update if the status is 'sent'
      expect(@message.buffer_update.sent_from_date_time).to eq('2015-09-17 14:35:22 +0000')
      # When Buffer sends out a message on a social media platform, it stores an ID supplied by the social media platform
      expect(@message.buffer_update.service_update_id).to eq('644520020861681664')
      # Did the message copy over the service_update_id from Buffer?
      expect(@message.social_network_id).to eq('644520020861681664')
      expect(@message.metrics.length).not_to eq(0)
      expect(@message.metrics[0].source).to eq(:buffer)
      expect(@message.metrics[0].data).not_to eq(0)
      # The call should have automatically saved both the message and the new Buffer update
      expect(@message.persisted?).to be_truthy
      expect(@message.buffer_update.persisted?).to be_truthy
    end
  end
end