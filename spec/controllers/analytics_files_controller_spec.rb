require 'rails_helper'

RSpec.describe AnalyticsFilesController, type: :controller do
  before do
    sign_in create(:administrator)
  end

  describe 'PATCH update' do
    before do
      @analytics_file = create(:analytics_file)
      patch :update, id: @analytics_file.id, url: 'http://www.newurl.com'
    end

    context 'with valid attributes' do
      it "changes the analtytics file's attributes" do
        @analytics_file.reload
        expect(@analytics_file.url).to eq('http://www.newurl.com')
      end
  
      it 'returns a success value of true and the id of the created analytics file' do
        expected_json = { success: true, id: @analytics_file.id }.to_json
  
        expect(response.header['Content-Type']).to match(/json/)
        expect(response.body).to eq(expected_json)
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :update, id: @analytics_file

      expect(response).to redirect_to :new_user_session
    end
  end
  
  describe 'GET #process_all_files' do
    before do
      allow(ProcessAnalyticsFilesJob).to receive(:perform_later)
    end

    before do
      get :process_all_files
    end

    it 'enqueues a job to process all analytics files' do
      expect(ProcessAnalyticsFilesJob).to have_received(:perform_later)
    end
    
    it 'sets a notice' do
      expect(flash[:notice]).to eq('All analytics files have been submitted for processing.')
    end

    it 'redirects to the root URL' do
      expect(response).to redirect_to root_url
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :process_all_files

      expect(response).to redirect_to :new_user_session
    end
  end
end