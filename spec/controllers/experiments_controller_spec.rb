require 'rails_helper'

RSpec.describe ExperimentsController, type: :controller do
  before do
    sign_in create(:administrator)

    # Create a set of saved social media profiles for use in these tests
    @social_media_profiles = create_list(:social_media_profile, 3)
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
      @experiment_messages = double('experiment_messages')
      @ordered_messages = []
      @paged_messages = double('paged_messages')
      allow(Message).to receive(:where).with(:message_generating_id => @experiment.id).and_return(@experiment_messages)
      allow(@experiment_messages).to receive(:page).and_return(@paged_messages)
      allow(@paged_messages).to receive(:order).and_return(@ordered_messages)
      @tag_list = ['tag-1', 'tag-2']
      @tag_matcher = double('tag_matcher')
      get :show, id: @experiment, page: '2'
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

    it 'assigns all messages to @messages' do
      expect(Message).to have_received(:where).with(:message_generating_id => @experiment.id)
      expect(@experiment_messages).to have_received(:page).with('2')
      expect(@paged_messages).to have_received(:order).with('created_at ASC')
      expect(assigns(:messages)).to eq(@ordered_messages)
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
      allow(GenerateMessagesJob).to receive(:perform_later)
    end

    context 'HTML format' do
      before do
        get :create_messages, id: @experiment, format: 'html'
      end

      it 'enqueues a job to generate the messages' do
        expect(GenerateMessagesJob).to have_received(:perform_later).with(an_instance_of(Experiment))
      end

      it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :create_messages, id: @experiment

        expect(response).to redirect_to :new_user_session
      end
    end

    context 'JSON format' do
      before do
        get :create_messages, id: @experiment, format: 'json'
      end

      it 'enqueues a job to generate the messages' do
        expect(GenerateMessagesJob).to have_received(:perform_later).with(an_instance_of(Experiment))
      end

      it 'returns success' do
        expected_json = { :success => true }.to_json

        expect(response.body).to eq(expected_json)
      end

      it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :create_messages, id: @experiment

        expect(response).to redirect_to :new_user_session
      end
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
    before do
      @experiment = build(:experiment)
      # Make sure that we have a social media profile that will suit the social media profile validations
      @social_media_profiles[0].platform = :facebook
      @social_media_profiles[0].allowed_mediums = [:ad]
      @social_media_profiles[0].save
      allow(DataDictionary).to receive(:create_data_dictionary)
    end

    context 'with valid attributes' do
      it 'creates a new experiment' do
        expect {
          post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set), posting_times: '4:09 PM', social_media_profile_ids: [@social_media_profiles[0].id])
        }.to change(Experiment, :count).by(1)
      end

      it 'creates an associated message generation parameter set' do
        expect {
          post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set), posting_times: '4:09 PM', social_media_profile_ids: [@social_media_profiles[0].id])
        }.to change(MessageGenerationParameterSet, :count).by(1)
        expect(MessageGenerationParameterSet.first.message_generating).not_to be_nil
      end
      
      it 'creates an empty data dictionary' do
        post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set), posting_times: '4:09 PM', social_media_profile_ids: [@social_media_profiles[0].id])

        expect(DataDictionary).to have_received(:create_data_dictionary).with(Experiment.first)
      end

      it 'redirects to the experiment workspace' do
        post :create, experiment: attributes_for(:experiment, message_generation_parameter_set_attributes: attributes_for(:message_generation_parameter_set), posting_times: '4:09 PM', social_media_profile_ids: [@social_media_profiles[0].id])
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
      @social_media_profiles[1].platform = :twitter
      @social_media_profiles[1].allowed_mediums = [:organic]
      @social_media_profiles[1].save
      @social_media_profiles[2].platform = :facebook
      @social_media_profiles[2].allowed_mediums = [:organic]
      @social_media_profiles[2].save
      patch :update, id: @experiment, experiment: attributes_for(:experiment, name: 'New name', end_date: Time.local(2000, 2, 1, 9, 0, 0), message_distribution_start_date: Time.local(2000, 3, 1, 9, 0, 0), posting_times: '4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM', social_media_profile_ids: [@social_media_profiles[1].id, @social_media_profiles[2].id], message_generation_parameter_set_attributes: {number_of_cycles: 4, number_of_messages_per_social_network: 5, social_network_choices: ['facebook', 'twitter'], medium_choices: ['organic'], image_present_choices: :no_messages})
    end

    context 'with valid attributes' do
      it 'locates the requested experiment' do
        expect(assigns(:experiment)).to eq(@experiment)
      end

      it "changes the experiment's attributes" do
        @experiment.reload
        expect(@experiment.name).to eq('New name')
        expect(@experiment.message_distribution_start_date).to eq(Time.local(2000, 3, 1, 9, 0, 0))
        expect(@experiment.end_date).to eq(Time.local(2000, 2, 1, 9, 0, 0))
        expect(@experiment.message_distribution_start_date).to eq(Time.local(2000, 3, 1, 9, 0, 0))
        expect(@experiment.posting_times).to eq('4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM')
      end

      it "changes the associated message generation parameter set's attribute" do
        @experiment.reload
        expect(@experiment.message_generation_parameter_set.social_network_choices).to eq([:facebook, :twitter])
        expect(@experiment.message_generation_parameter_set.medium_choices).to eq([:organic])
        expect(@experiment.message_generation_parameter_set.image_present_choices).to eq(:no_messages)
        expect(@experiment.message_generation_parameter_set.number_of_cycles).to eq(4)
        expect(@experiment.message_generation_parameter_set.number_of_messages_per_social_network).to eq(5)
      end

      it "changes the associated social media profiles" do
        @experiment.reload
        expect(@experiment.social_media_profiles.count).to eq(2)
        expect(@experiment.social_media_profiles[0]).to eq(@social_media_profiles[1])
        expect(@experiment.social_media_profiles[1]).to eq(@social_media_profiles[2])
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