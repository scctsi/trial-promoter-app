require 'rails_helper'

RSpec.describe MessageTemplatesController, type: :controller do
    before do
      sign_in create(:administrator)
    end

   describe 'GET #index' do
    let(:message_templates) { build_pair(:message_template) }


    before do
      allow(MessageTemplate).to receive(:all).and_return(message_templates)
      get :index
    end

    it 'assigns all existing message templates to @message_templates' do
      expect(assigns(:message_templates)).to eq(message_templates)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :index }

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :index

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #import' do
    it 'imports message templates from an Excel file accessible at a URL' do
      experiment = create(:experiment)
      excel_url = 'http://sc-ctsi.org/trial-promoter/message_templates.xlsx'
      expected_json = { success: true, imported_count: 2}.to_json

      message_template_importer = nil
      VCR.use_cassette 'message_templates/import' do
        excel_file_reader = ExcelFileReader.new
        message_template_importer = MessageTemplateImporter.new(excel_file_reader.read(excel_url), experiment.to_param)
        allow(MessageTemplateImporter).to receive(:new).with(instance_of(Array), experiment.to_param).and_return(message_template_importer)
        allow(message_template_importer).to receive(:import).and_call_original
        get :import, url: excel_url, experiment_id: experiment.id
      end

      expect(MessageTemplate.count).to eq(2)
      expect(MessageTemplateImporter).to have_received(:new).with(instance_of(Array), experiment.to_param)
      expect(message_template_importer).to have_received(:import)
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :import

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #get_image_selections' do
    before do
      @experiments = create_list(:experiment, 2)
      @images = create_list(:image, 5)
      @images[0..3].each do |image|
        image.experiment_list = @experiments[0].to_param
        image.save
      end
      @message_templates = create_list(:message_template, 3)
    end

    it 'returns a list of all the selected and unselected images for a message template' do
      image_pool_manager = ImagePoolManager.new
      selected_and_unselected_images = image_pool_manager.get_selected_and_unselected_images(@experiments[0], @message_templates[0])

      post :get_image_selections, id: @message_templates[0].id, experiment_id: @experiments[0].id

      expected_json = { success: true, selected_images: selected_and_unselected_images[:selected_images], unselected_images: selected_and_unselected_images[:unselected_images] }.to_json
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :get_image_selections, id: @message_templates[0].id

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #add_image_to_image_pool' do
    before do
      @images = create_list(:image, 5)
      @message_templates = create_list(:message_template, 3)
    end

    it 'adds an image to the image pool for a message template' do
      post :add_image_to_image_pool, id: @message_templates[0].id, image_id: @images[1].id

      expected_json = { success: true }.to_json
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
      @message_templates[0].reload
      expect(@message_templates[0].image_pool).to eq([@images[1].id])
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :add_image_to_image_pool, id: @message_templates[0].id

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #remove_image_from_image_pool' do
    before do
      @images = create_list(:image, 5)
      @message_templates = create_list(:message_template, 3)
    end

    it 'removes an image from the image pool for a message template' do
      ImagePoolManager.new.add_images([@images[0].id, @images[2].id, @images[4].id], @message_templates[0])
      post :remove_image_from_image_pool, id: @message_templates[0].id, image_id: @images[2].id

      expected_json = { success: true }.to_json
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
      @message_templates[0].reload
      expect(@message_templates[0].image_pool).to eq([@images[0].id, @images[4].id])
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :remove_image_from_image_pool, id: @message_templates[0].id

      expect(response).to redirect_to :new_user_session
    end
  end
end