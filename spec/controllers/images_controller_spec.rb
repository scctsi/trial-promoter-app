require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new image' do
        expect {
          post :create, image: attributes_for(:image)
        }.to change(Image, :count).by(1)
      end

      it 'returns a success value of true and the id of the created image' do
        post :create, image: attributes_for(:image)
        expected_json = { success: true, id: Image.first.id }.to_json
        
        expect(response.header['Content-Type']).to match(/json/)
        expect(response.body).to eq(expected_json)
      end
    end
  end
  
  describe 'POST #import' do
    it 'imports multiple images accessible at multiple URLs' do
      experiment = create(:experiment)
      image_importer = ImageImporter.new
      allow(ImageImporter).to receive(:new).and_return(image_importer)
      allow(image_importer).to receive(:import).and_call_original
      image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
      expected_json = { success: true, imported_count: image_urls.length}.to_json

      VCR.use_cassette 'images/import' do
        post :import, image_urls: image_urls, experiment_id: experiment.id
      end

      expect(Image.count).to eq(image_urls.length)
      expect(image_importer).to have_received(:import).with(image_urls, experiment.to_param)
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end
  end
end
