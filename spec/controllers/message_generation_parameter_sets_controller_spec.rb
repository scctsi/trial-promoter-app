require 'rails_helper'

RSpec.describe MessageGenerationParameterSetsController, type: :controller do
  describe 'GET #new' do
    before do
      experiment = create(:experiment)
      get :new, {experiment_id: experiment}
    end
    
    it 'assigns a new message generation parameter set to @message_generation_parameter_set' do
      expect(assigns(:message_generation_parameter_set)).to be_a_new(MessageGenerationParameterSet)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end
  
  describe 'GET #edit' do
    before do
      experiment = create(:experiment)
      message_generation_parameter_set = create(:message_generation_parameter_set)
      get :edit, {experiment_id: experiment, id: message_generation_parameter_set.id}
    end
    
    it 'assigns the requested message generation parameter set to @message_generation_parameter_set' do
      expect(assigns(:message_generation_parameter_set)).to eq(@message_generation_parameter_set)
    end
    
    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      before do
        @experiment = create(:experiment)
      end
      
      it 'creates a new message generation parameter set' do
        expect {
          post :create, message_generation_parameter_set: attributes_for(:message_generation_parameter_set), experiment_id: @experiment
        }.to change(MessageGenerationParameterSet, :count).by(1)
      end
      
      it 'redirects to the experiment page' do
        post :create, message_generation_parameter_set: attributes_for(:message_generation_parameter_set), experiment_id: experiment
        expect(response).to redirect_to experiment_url(experiment)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the message generation parameter set to the database' do
        expect {
          post :create, message_generation_parameter_set: attributes_for(:invalid_message_generation_parameter_set), experiment_id: @experiment
        }.to_not change(MessageGenerationParameterSet, :count)
      end
      
      it "re-renders the new template" do
        post :create, message_generation_parameter_set: attributes_for(:invalid_message_generation_parameter_set), experiment_id: @experiment
        expect(response).to render_template :new
      end
    end
  end
  
  # describe 'PATCH update' do
  #   before :each do
  #     @message_template = create(:message_template)
  #     patch :update, id: @message_template, message_template: attributes_for(:message_template, content: 'New content', platform: :facebook)
  #   end
    
  #   context 'with valid attributes' do
  #     it 'locates the requested message template' do
  #       expect(assigns(:message_template)).to eq(@message_template)
  #     end
    
  #     it "changes the message template's attributes" do
  #       @message_template.reload
  #       expect(@message_template.content).to eq('New content')
  #       expect(@message_template.platform).to eq(:facebook)
  #     end
    
  #     it 'redirects to the index page' do
  #       expect(response).to redirect_to message_templates_url
  #     end
  #   end
  # end
end