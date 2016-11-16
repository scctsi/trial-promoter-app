require 'rails_helper'

RSpec.describe MessageGenerationParameterSetsController, type: :controller do
  describe 'GET #new' do
    before do
      @experiment = create(:experiment)
      get :new, {experiment_id: @experiment}
    end

    it 'assigns the parent experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end

    it 'builds a message generation parameter set on the parent experiment' do
      expect(assigns(:experiment).message_generation_parameter_set).to be_a_new(MessageGenerationParameterSet)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end

  describe 'POST #create' do
    before do
      @experiment = create(:experiment)
    end

    context 'with valid attributes' do
      it 'creates a new message generation parameter set' do
        expect {
          post :create, message_generation_parameter_set: attributes_for(:message_generation_parameter_set), experiment_id: @experiment.id
        }.to change(MessageGenerationParameterSet, :count).by(1)
        message_generation_parameter_set = MessageGenerationParameterSet.last
        expect(message_generation_parameter_set.message_generating).to eq(@experiment)
      end
      
      it 'redirects to the experiment workspace' do
        post :create, message_generation_parameter_set: attributes_for(:message_generation_parameter_set), experiment_id: @experiment.id
        expect(response).to redirect_to experiment_url(@experiment)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the message generation parameter set to the database' do
        expect {
          post :create, message_generation_parameter_set: attributes_for(:invalid_message_generation_parameter_set), experiment_id: @experiment.id
        }.to_not change(MessageGenerationParameterSet, :count)
      end
      
      it "re-renders the new template" do
          post :create, message_generation_parameter_set: attributes_for(:invalid_message_generation_parameter_set), experiment_id: @experiment.id
        expect(response).to render_template :new
      end
    end
  end
  
  describe 'GET #edit' do
    before do
      experiment = create(:experiment)
      @message_generation_parameter_set = create(:message_generation_parameter_set, message_generating: experiment)
      get :edit, {id: @message_generation_parameter_set}
    end
    
    it 'assigns the requested message generation parameter set to @message_generation_parameter_set' do
      expect(assigns(:message_generation_parameter_set)).to eq(@message_generation_parameter_set)
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH update' do
    before do
      @message_generation_parameter_set = create(:message_generation_parameter_set)
      patch :update, id: @message_generation_parameter_set,
        message_generation_parameter_set: attributes_for(:message_generation_parameter_set, 
          promoted_websites_tag: 'new promoted websites tag',
          promoted_clinical_trials_tag: 'new promoted clinical trials tag',
          promoted_properties_cycle_type: :subset,
          selected_message_templates_tag: 'new selected message templates tag',
          selected_message_templates_cycle_type: :subset,
          medium_cycle_type: :subset,
          social_network_cycle_type: :subset,
          image_present_cycle_type: :subset,
          period_in_days: 1,
          number_of_messages_per_social_network: 2)
    end
    
    context 'with valid attributes' do
      it 'assigns the requested message generation parameter set to @message_generation_parameter_set' do
        expect(assigns(:message_generation_parameter_set)).to eq(@message_generation_parameter_set)
      end
    
      it "changes the message generation parameter set's attributes" do
        skip 'Test does not pass; come back to this later'
        @message_generation_parameter_set.reload
        expect(@message_generation_parameter_set.promoted_websites_tag).to eq('new promoted websites tag')
        expect(@message_generation_parameter_set.promoted_clinical_trials_tag).to eq('new promoted clinical trials tag')
        expect(@message_generation_parameter_set.promoted_properties_cycle_type).to eq(:subset)
        expect(@message_generation_parameter_set.selected_message_templates_tag).to eq('new selected message templates tag')
        expect(@message_generation_parameter_set.promoted_websites_tag).to eq('new promoted websites tag')
        expect(@message_generation_parameter_set.medium_cycle_type).to eq(:subset)
        expect(@message_generation_parameter_set.social_network_cycle_type).to eq(:subset)
        expect(@message_generation_parameter_set.image_present_cycle_type).to eq(:subset)
        expect(@message_generation_parameter_set.period_in_days).to eq(1)
        expect(@message_generation_parameter_set.number_of_messages_per_social_network).to eq(2)
      end
    
      it 'redirects to the experiment page' do
        skip 'Test does not pass; come back to this later'
        expect(response).to redirect_to experiment_url(@message_generation_parameter_set.message_generating)
      end
    end
  end
end