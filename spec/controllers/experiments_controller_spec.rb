require 'rails_helper'

RSpec.describe ExperimentsController, type: :controller do
  before do
    sign_in create(:administrator)
  end

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

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :index

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #show' do
    before do
      @experiment = create(:experiment)
      @message_templates = []
      allow(MessageTemplate).to receive(:belonging_to).with(@experiment).and_return(@message_templates)
      @images = []
      allow(Image).to receive(:belonging_to).with(@experiment).and_return(@images)
      @websites = []
      allow(Website).to receive(:belonging_to).with(@experiment).and_return(@websites)
      @messages = []
      allow(Message).to receive(:all).and_return(@messages)
      get :show, id: @experiment
    end

    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end

    it 'assigns all message templates tagged with the experiments parameterized slug (on the experiments context) to @message_templates' do
      expect(MessageTemplate).to have_received(:belonging_to).with(@experiment)
      expect(assigns(:message_templates)).to eq(@message_templates)
    end

    it 'assigns all images tagged with the experiments parameterized slug (on the experiments context) to @images' do
      expect(Image).to have_received(:belonging_to).with(@experiment)
      expect(assigns(:images)).to eq(@images)
    end

    it 'assigns all websites tagged with the experiments parameterized slug (on the experiments context) to @websites' do
      expect(Website).to have_received(:belonging_to).with(@experiment)
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

    it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :show, id: @experiment

        expect(response).to redirect_to :new_user_session
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

  describe 'GET #create_messages' do
    before do
      @experiment = create(:experiment)
      allow(Experiment).to receive(:find).and_return(@experiment)
      allow(@experiment).to receive(:create_messages)
      get :create_messages, id: @experiment
    end

    it 'asks the experiment to create messages' do
      expect(@experiment).to have_received(:create_messages)
    end

    it 'redirects to the experiment workspace' do
      expect(response).to redirect_to experiment_url(Experiment.first)
    end

    it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :create_messages, id: @experiment

        expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #create_analytics_file_todos' do
    before do
      @experiment = create(:experiment)
      allow(Experiment).to receive(:find).and_return(@experiment)
      allow(@experiment).to receive(:create_analytics_file_todos)
      get :create_analytics_file_todos, id: @experiment
    end

    it 'asks the experiment to create analytics file todos' do
      expect(@experiment).to have_received(:create_analytics_file_todos)
    end

    it 'redirects to the experiment workspace' do
      expect(response).to redirect_to experiment_url(Experiment.first)
    end

    it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :create_analytics_file_todos, id: @experiment

        expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #new' do
    before do
      @experiment = Experiment.new
      allow(Experiment).to receive(:new).and_return(@experiment)
      get :new
    end

    it 'assigns a new experiment to @experiment' do
      expect(assigns(:experiment)).to be_a_new(Experiment)
    end

    it 'builds an associated message generation parameter set' do
      expect(@experiment.message_generation_parameter_set).not_to be_nil
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
      @experiment = create(:experiment)
      get :edit, id: @experiment
    end

    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :edit, id: @experiment

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new experiment' do
        expect {
          post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set))
        }.to change(Experiment, :count).by(1)
      end

      it 'creates an associated message generation parameter set' do
        expect {
          post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set))
        }.to change(MessageGenerationParameterSet, :count).by(1)
        expect(MessageGenerationParameterSet.first.message_generating).not_to be_nil
      end

      it 'redirects to the experiment workspace' do
        post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set))
        expect(response).to redirect_to experiment_url(Experiment.first)
      end

      it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        post :create

        expect(response).to redirect_to :new_user_session
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
      @experiment.message_generation_parameter_set = create(:message_generation_parameter_set, message_generating: @experiment)
      patch :update, id: @experiment, experiment: attributes_for(:experiment, name: 'New name', start_date: Time.local(2000, 1, 1, 9, 0, 0), end_date: Time.local(2000, 2, 1, 9, 0, 0), message_distribution_start_date: Time.local(2000, 3, 1, 9, 0, 0),
                                      message_generation_parameter_set_attributes: {social_network_distribution: :random, medium_distribution: :random, image_present_distribution: :random, period_in_days: 10, number_of_messages_per_social_network: 5, social_network_choices: ['facebook', 'instagram', ''], medium_choices: ['ad', 'organic'], image_present_choices: ['with', 'without']})
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
      end

      it "changes the associated message generation parameter set's attribute" do
        @experiment.reload
        expect(@experiment.message_generation_parameter_set.social_network_choices).to eq([:facebook, :instagram])
        expect(@experiment.message_generation_parameter_set.medium_choices).to eq([:ad, :organic])
        expect(@experiment.message_generation_parameter_set.image_present_choices).to eq([:with, :without])
        expect(@experiment.message_generation_parameter_set.social_network_distribution).to eq(:random)
        expect(@experiment.message_generation_parameter_set.medium_distribution).to eq(:random)
        expect(@experiment.message_generation_parameter_set.image_present_distribution).to eq(:random)
        expect(@experiment.message_generation_parameter_set.period_in_days).to eq(10)
        expect(@experiment.message_generation_parameter_set.number_of_messages_per_social_network).to eq(5)
      end

      it 'redirects to the experiment workspace' do
        expect(response).to redirect_to experiment_url(Experiment.first)
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      patch :update, id: @experiment

      expect(response).to redirect_to :new_user_session
    end
  end
end