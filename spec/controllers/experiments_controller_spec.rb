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
  
  # # describe "GET #show" do
  # #   it "assigns the requested contact to @contact"
  # #   it "renders the :show template"
  # # end
  
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
