require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  before do
    sign_in create(:administrator)
  end
  
  describe 'GET #check_validity_for_instagram_ads' do
    before do
      allow(CheckValidityForInstagramAdsJob).to receive(:perform_later)
    end

    before do
      get :check_validity_for_instagram_ads
    end

    it 'enqueues a job to check the validity of images for instagram ads' do
      expect(CheckValidityForInstagramAdsJob).to have_received(:perform_later)
    end
    
    it 'sets a notice' do
      expect(flash[:notice]).to eq('Images are being checked for validity in Instagram ads')
    end

    it 'redirects to the root url' do
      expect(response).to redirect_to root_url
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :check_validity_for_instagram_ads

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #import' do
    it 'imports multiple images uploaded to cloud storage' do
      experiment = create(:experiment)
      image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
      original_filenames = ['filename1.ext', 'filename2.ext']
      expected_json = { success: true, imported_count: image_urls.length}.to_json

      post :import, image_urls: image_urls, original_filenames: original_filenames, experiment_id: experiment.id

      expect(Image.count).to eq(image_urls.length)
      image = Image.first
      expect(image.url).to eq(image_urls[0])
      expect(image.original_filename).to eq(original_filenames[0])
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :import

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #add' do
    it 'adds multiple images uploaded to cloud storage' do
      s3_client_double = double('s3_client')
      allow(S3Client).to receive(:new).and_return(s3_client_double)
      allow(s3_client_double).to receive(:delete)
      allow(s3_client_double).to receive(:bucket)
      allow(s3_client_double).to receive(:key)
      experiment = create(:experiment)
      # Create 2 images associated with this experiment
      create_list(:image, 2, experiment_list: [experiment.to_param])
      image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
      original_filenames = ['filename1.ext', 'filename2.ext']
      expected_json = { success: true, imported_count: image_urls.length}.to_json

      post :add, image_urls: image_urls, original_filenames: original_filenames, experiment_id: experiment.id

      expect(Image.count).to eq(image_urls.length + 2)
      image = Image.third
      expect(image.url).to eq(image_urls[0])
      expect(image.original_filename).to eq(original_filenames[0])
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :add

      expect(response).to redirect_to :new_user_session
    end
  end
end