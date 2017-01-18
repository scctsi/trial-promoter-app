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

  describe 'GET #new' do
    before do
      get :new
    end

    it 'assigns a new message template to @message_template' do
      expect(assigns(:message_template)).to be_a_new(MessageTemplate)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :new

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #edit' do
    before do
      @message_template = create(:message_template)
      get :edit, id: @message_template
    end

    it 'assigns the requested message template to @message_template' do
      expect(assigns(:message_template)).to eq(@message_template)
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :edit, id: @message_template

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new message template' do
        expect {
          post :create, message_template: attributes_for(:message_template)
        }.to change(MessageTemplate, :count).by(1)
      end

      it 'redirects to the index page' do
        post :create, message_template: attributes_for(:message_template)
        expect(response).to redirect_to message_templates_url
      end
    end

    context 'with invalid attributes' do
      it 'does not save the message template to the database' do
        expect {
          post :create, message_template: attributes_for(:invalid_message_template)
        }.to_not change(MessageTemplate, :count)
      end

      it "re-renders the new template" do
        post :create, message_template: attributes_for(:invalid_message_template)
        expect(response).to render_template :new
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :create

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'PATCH update' do
    before :each do
      @message_template = create(:message_template)
      patch :update, id: @message_template, message_template: attributes_for(:message_template, content: 'New content', platform: :facebook)
    end

    context 'with valid attributes' do
      it 'locates the requested message template' do
        expect(assigns(:message_template)).to eq(@message_template)
      end

      it "changes the message template's attributes" do
        @message_template.reload
        expect(@message_template.content).to eq('New content')
        expect(@message_template.platform).to eq(:facebook)
      end

      it 'redirects to the index page' do
        expect(response).to redirect_to message_templates_url
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      patch :update, id: @message_template

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #import' do
    it 'imports message templates from a CSV file accessible at a URL' do
      experiment = create(:experiment)
      csv_url = 'http://sc-ctsi.org/trial-promoter/message_templates.csv'
      expected_json = { success: true, imported_count: 2}.to_json

      message_template_importer = nil
      VCR.use_cassette 'message_templates/import' do
        csv_file_reader = CsvFileReader.new
        message_template_importer = MessageTemplateImporter.new(csv_file_reader.read(csv_url), experiment.to_param)
        allow(MessageTemplateImporter).to receive(:new).with(instance_of(Array), experiment.to_param).and_return(message_template_importer)
        allow(message_template_importer).to receive(:import).and_call_original
        get :import, url: csv_url, experiment_id: experiment.id
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
end