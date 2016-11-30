require 'rails_helper'

RSpec.describe ExperimentsController, type: :controller do
  describe 'GET #index' do
    let(:experiments) { build_pair(:experiment) }
  
    before do
      allow(Experiment).to receive(:all).and_return(experiments)
      get :index
    end
    
    it 'assigns all existing experiments to @experiments' do
      expect(assigns(:experiments)).to eq(experiments)
    end
    
    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :index }
  end
  
  describe 'GET #show' do
    before do
      @message_templates = []
      allow(MessageTemplate).to receive(:tagged_with).and_return(@message_templates)
      @images = []
      allow(Image).to receive(:tagged_with).and_return(@images)
      @websites = []
      allow(Website).to receive(:tagged_with).and_return(@websites)
      @experiment = create(:experiment)
      @messages = []
      allow(Message).to receive(:all).and_return(@messages)
      get :show, id: @experiment
    end
    
    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end
    
    it 'assigns all message templates tagged with the experiments parameterized slug to @message_templates' do
      expect(MessageTemplate).to have_received(:tagged_with).with("#{@experiment.to_param}")
      expect(assigns(:message_templates)).to eq(@message_templates)
    end

    it 'assigns all images tagged with the experiments parameterized slug to @images' do
      expect(Image).to have_received(:tagged_with).with("#{@experiment.to_param}")
      expect(assigns(:images)).to eq(@images)
    end

    it 'assigns all websites tagged with the experiments parameterized slug to @websites' do
      expect(Website).to have_received(:tagged_with).with("#{@experiment.to_param}")
      expect(assigns(:websites)).to eq(@websites)
    end

    it 'assigns all messages to @messages' do
      expect(Message).to have_received(:all)
      expect(assigns(:messages)).to eq(@messages)
    end

    it 'uses the workspace layout' do
      expect(response).to render_template :workspace
    end
    
    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
  
  describe 'GET #parameterized_slug' do
    before do
      @experiment = create(:experiment)
      get :parameterized_slug, id: @experiment
    end
    
    it 'returns the to_param value for the experiment in the JSON response' do
      expected_json = { :parameterized_slug => @experiment.to_param }.to_json
      
      expect(response.header['Content-Type']).to match(/json/)
      expect(response.body).to eq(expected_json)
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end
    
    it 'assigns a new experiment to @experiment' do
      expect(assigns(:experiment)).to be_a_new(Experiment)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :new }
  end
  
  describe 'GET #edit' do
    before do
      @experiment = create(:experiment)
      get :edit, id: @experiment
    end
    
    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end
    
    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end
  
  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new experiment' do
        expect {
          post :create, experiment: attributes_for(:experiment)
        }.to change(Experiment, :count).by(1)
      end
      
      it 'redirects to the index page' do
        post :create, experiment: attributes_for(:experiment)
        expect(response).to redirect_to experiments_url
      end
    end

    context 'with invalid attributes' do
      it 'does not save the experiment to the database' do
        expect {
          post :create, experiment: attributes_for(:invalid_experiment)
        }.to_not change(Experiment, :count)
      end
      
      it 're-renders the new template' do
        post :create, experiment: attributes_for(:invalid_experiment)
        expect(response).to render_template :new
      end
    end
  end
  
  describe 'PATCH update' do
    before :each do
      @experiment = create(:experiment)
      @clinical_trials = create_pair(:clinical_trial)
      patch :update, id: @experiment, experiment: attributes_for(:experiment, name: 'New name', start_date: Time.local(2000, 1, 1, 9, 0, 0), end_date: Time.local(2000, 2, 1, 9, 0, 0), message_distribution_start_date: Time.local(2000, 3, 1, 9, 0, 0), clinical_trial_ids: [@clinical_trials[0].id, @clinical_trials[1].id])
    end
    
    context 'with valid attributes' do
      it 'locates the requested experiment' do
        expect(assigns(:experiment)).to eq(@experiment)
      end
    
      it "changes the experiment's attributes" do
        @experiment.reload
        expect(@experiment.name).to eq('New name')
        expect(@experiment.start_date).to eq(Time.local(2000, 1, 1, 9, 0, 0))
        expect(@experiment.end_date).to eq(Time.local(2000, 2, 1, 9, 0, 0))
        expect(@experiment.message_distribution_start_date).to eq(Time.local(2000, 3, 1, 9, 0, 0))
        expect(@experiment.clinical_trials).to include(@clinical_trials[0])
        expect(@experiment.clinical_trials).to include(@clinical_trials[1])
      end
    
      it 'redirects to the index page' do
        expect(response).to redirect_to experiments_url
      end
    end
  end
end
