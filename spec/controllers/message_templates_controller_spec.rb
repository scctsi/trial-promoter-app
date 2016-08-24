require 'rails_helper'

RSpec.describe MessageTemplatesController, type: :controller do
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
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new message_template' do
        expect {
          post :create, message_template: attributes_for(:message_template)
        }.to change(MessageTemplate, :count).by(1)
      end
      
      it 'redirects to the message templates index page' do
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
  end
  
  describe 'PUT update' do
    before :each do
      @message_template = create(:message_template)
      patch :update, id: @message_template, message_template: attributes_for(:message_template, content: 'New content', platform: :facebook)
    end
    
    context 'with valid attributes' do
      it 'locates the requested message template' do
        assigns(:message_template).should eq(@message_template)
      end
    
      it "changes the message template's attributes" do
        @message_template.reload
        @message_template.content.should eq('New content')
        @message_template.platform.should eq(:facebook)
      end
    
      it 'redirects to the updated message template' do
        response.should redirect_to @message_template
      end
    end
  end
end