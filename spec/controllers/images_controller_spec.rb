require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  before do
    sign_in create(:administrator)
  end

  describe 'POST #import' do
    it 'imports multiple images accessible at multiple URLs' do
      experiment = create(:experiment)
      image_urls = ['http://www.images.com/image1.png', 'http://www.images.com/image2.png']
      expected_json = { success: true, imported_count: image_urls.length}.to_json

      image_importer = nil
      VCR.use_cassette 'images/import' do
        image_importer = ImageImporter.new(image_urls, experiment.to_param)
        allow(ImageImporter).to receive(:new).with(instance_of(Array), experiment.to_param).and_return(image_importer)
        allow(image_importer).to receive(:import).and_call_original
        post :import, image_urls: image_urls, experiment_id: experiment.id
      end

      expect(Image.count).to eq(image_urls.length)
      expect(ImageImporter).to have_received(:new).with(instance_of(Array), experiment.to_param)
      expect(image_importer).to have_received(:import)
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :import

      expect(response).to redirect_to :new_user_session
    end
  end
  
  describe 'POST #tag-images' do
    before do
      @images = create_list(:image, 5)
    end
    
    it 'adds tags to existing images' do
      image_ids = @images.map(&:id)
      tags = ['tag-1', 'tag-2']
      expected_json = { success: true, tagged_count: image_ids.length}.to_json

      post :tag_images, image_ids: image_ids, tags: tags

      Image.all.each{ |image| expect(image.tag_list).to eq(['tag-1', 'tag-2']) }
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'replaces all existing tags on the images' do
      Image.all.each do |image| 
        image.tag_list = ['old-tag-1', 'old-tag-2']
        image.save
      end
      image_ids = @images.map(&:id)
      tags = ['tag-1', 'tag-2']
      expected_json = { success: true, tagged_count: image_ids.length}.to_json

      post :tag_images, image_ids: image_ids, tags: tags

      Image.all.each{ |image| expect(image.tag_list).to eq(['tag-1', 'tag-2']) }
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :tag_images

      expect(response).to redirect_to :new_user_session
    end
  end
end