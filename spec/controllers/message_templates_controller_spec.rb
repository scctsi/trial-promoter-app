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
    
    it { should respond_with :ok }
    it { should render_template :index }
  end

  describe 'GET #new' do
    before do
      get :new
    end
    
    it 'assigns a new message template to @message_template' do
      expect(assigns(:message_template)).to be_a_new(MessageTemplate)
    end

    it { should respond_with :ok }
    it { should render_template :new }
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
    
    context "with invalid attributes" do
      # it "does not save the new contact in the database"
      # it "re-renders the :new template"
    end
  end
end

# require 'rails_helper'

# RSpec.describe CampaignsController, type: :controller do
# 
#   # describe "GET #show" do
#   #   it "assigns the requested contact to @contact"
#   #   it "renders the :show template"
#   # end
  
# end
