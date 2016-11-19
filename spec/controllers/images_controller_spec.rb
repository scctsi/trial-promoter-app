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
end
