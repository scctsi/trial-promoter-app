require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  before do
    sign_in create(:administrator)
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
end