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
      allow(@paged_messages).to receive(:order).with('scheduled_date_time ASC').and_return(@ordered_messages)

      # Test set up for calculating the top 5 messages by click rate
      @top_messages_by_click_rate_double = double('top_messages_by_click_rate_double')
      allow(Message).to receive(:where).with('message_generating_id = ? AND click_rate is not null', @experiment.id).and_return(@top_messages_by_click_rate_double)
      @ordered_top_messages_by_click_rate_double = double('ordered_top_messages_by_click_rate_double')
      allow(@top_messages_by_click_rate_double).to receive(:order).with('click_rate desc').and_return(@ordered_top_messages_by_click_rate_double)

      # Test set up for calculating the top 5 messages by goal rate
      @top_messages_by_website_goal_rate_double = double('top_messages_by_website_goal_rate_double')
      allow(Message).to receive(:where).with('message_generating_id = ? AND website_goal_rate is not null', @experiment.id).and_return(@top_messages_by_website_goal_rate_double)
      @ordered_top_messages_by_website_goal_rate_double = double('ordered_top_messages_by_website_goal_rate_double')
      allow(@top_messages_by_website_goal_rate_double).to receive(:order).with('website_goal_rate desc').and_return(@ordered_top_messages_by_website_goal_rate_double)

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
      expect(@paged_messages).to have_received(:order).with('scheduled_date_time ASC')
      expect(assigns(:messages)).to eq(@ordered_messages)
    end

    it 'assigns the ordered messages with the highest click rate to @top_messages_by_click_rate' do
      expect(Message).to have_received(:where).with('message_generating_id = ? AND click_rate is not null', @experiment.id)
      expect(@top_messages_by_click_rate_double).to have_received(:order).with('click_rate desc')
      expect(assigns(:top_messages_by_click_rate)).to eq(@ordered_top_messages_by_click_rate_double)
    end

    it 'assigns the ordered messages with the highest goal rate to @top_messages_by_website_goal_rate' do
      expect(Message).to have_received(:where).with('message_generating_id = ? AND website_goal_rate is not null', @experiment.id)
      expect(@top_messages_by_website_goal_rate_double).to have_received(:order).with('website_goal_rate desc')
      expect(assigns(:top_messages_by_website_goal_rate)).to eq(@ordered_top_messages_by_website_goal_rate_double)
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

  describe 'GET #correctness_analysis' do
    before do
      @experiment = create(:experiment)
      get :correctness_analysis, id: @experiment
    end

    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end

    it 'uses the workspace layout' do
      expect(response).to render_template :workspace
    end

    it 'renders the correctness_analysis template' do
      expect(response).to render_template :correctness_analysis
    end

    it 'redirects unauthenticated user to sign-in page' do
        sign_out(:user)

        get :correctness_analysis, id: @experiment

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

      it 'assigns the requested experiment to @experiment' do
        expect(assigns(:experiment)).to eq(@experiment)
      end

      it 'enqueues a job to generate the messages' do
        expect(GenerateMessagesJob).to have_received(:perform_later).with(@experiment)
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

    context 'JSON format' do
      before do
        get :create_messages, id: @experiment, format: 'json'
      end

      it 'assigns the requested experiment to @experiment' do
        expect(assigns(:experiment)).to eq(@experiment)
      end

      it 'enqueues a job to generate the messages' do
        expect(GenerateMessagesJob).to have_received(:perform_later).with(@experiment)
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

  describe 'GET #send_to_buffer' do
    before do
      @experiment = create(:experiment)
      allow(PublishMessagesJob).to receive(:perform_later)
    end

    before do
      get :send_to_buffer, id: @experiment
    end

    it 'enqueues a job to generate the messages' do
      expect(PublishMessagesJob).to have_received(:perform_later)
    end

    it 'sets a notice' do
      expect(flash[:notice]).to eq('Messages scheduled for the next 7 days have been pushed to Buffer')
    end

    it 'redirects to the experiment workspace' do
      expect(response).to redirect_to experiment_url(Experiment.first)
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :send_to_buffer, id: @experiment

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
      @click_meter_groups = []
      @click_meter_domains = []
      allow(ClickMeterClient).to receive(:get_groups).and_return(@click_meter_groups)
      allow(ClickMeterClient).to receive(:get_domains).and_return(@click_meter_domains)
      get :new
    end

    it 'assigns a new experiment to @experiment' do
      expect(assigns(:experiment)).to be_a_new(Experiment)
    end

    it 'assigns the groups available through Click Meter' do
      expect(assigns(:click_meter_groups)).to eq(@click_meter_groups)
    end

    it 'assigns the domains available through Click Meter' do
      expect(assigns(:click_meter_domains)).to eq(@click_meter_domains)
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
      @click_meter_groups = []
      @click_meter_domains = []
      allow(ClickMeterClient).to receive(:get_groups).and_return(@click_meter_groups)
      allow(ClickMeterClient).to receive(:get_domains).and_return(@click_meter_domains)
      get :edit, id: @experiment
    end

    it 'assigns the requested experiment to @experiment' do
      expect(assigns(:experiment)).to eq(@experiment)
    end

    it 'assigns the groups available through Click Meter' do
      expect(assigns(:click_meter_groups)).to eq(@click_meter_groups)
    end

    it 'assigns the domains available through Click Meter' do
      expect(assigns(:click_meter_domains)).to eq(@click_meter_domains)
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
      patch :update, id: @experiment, experiment: attributes_for(:experiment, name: 'New name', message_distribution_start_date: Time.local(2000, 3, 1, 9, 0, 0), click_meter_group_id: 1, click_meter_domain_id: 2, facebook_posting_times: '4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM', instagram_posting_times: '4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM', twitter_posting_times: '4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM', social_media_profile_ids: [@social_media_profiles[1].id, @social_media_profiles[2].id], message_generation_parameter_set_attributes: {number_of_cycles: 4, number_of_messages_per_social_network: 5, social_network_choices: ['facebook', 'twitter'], medium_choices: ['organic'], image_present_choices: :no_messages})
    end

    context 'with valid attributes' do
      it 'locates the requested experiment' do
        expect(assigns(:experiment)).to eq(@experiment)
      end

      it "changes the experiment's attributes" do
        @experiment.reload
        expect(@experiment.name).to eq('New name')
        expect(@experiment.message_distribution_start_date).to eq(Time.local(2000, 3, 1, 9, 0, 0))
        expect(@experiment.message_distribution_start_date).to eq(Time.local(2000, 3, 1, 9, 0, 0))
        expect(@experiment.click_meter_group_id).to eq(1)
        expect(@experiment.click_meter_domain_id).to eq(2)
        expect(@experiment.twitter_posting_times).to eq('4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM')
        expect(@experiment.facebook_posting_times).to eq('4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM')
        expect(@experiment.instagram_posting_times).to eq('4:09 PM,6:22 PM,9:34 AM,10:02 PM,2:12 AM')
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

  describe 'GET #messages_page' do
    before do
      @messages = create_list(:message, 3)
      @experiment = create(:experiment)
      @experiment_messages = double('experiment_messages')
      @ordered_messages = []
      @paged_messages = double('paged_messages')
      allow(Message).to receive(:where).with(:message_generating_id => @experiment.id).and_return(@experiment_messages)
      allow(@experiment_messages).to receive(:page).and_return(@paged_messages)
      allow(@paged_messages).to receive(:order).and_return(@ordered_messages)
    end

    it 'renders generated messages' do

      get :messages_page, id: @experiment.id, page: '2'

      expect(response).to render_template("shared/_messages_page")
    end

    it 'redirects an unauthorized user' do
      sign_out(:user)

      get :messages_page, id: @experiment.id

      expect(response).to redirect_to :new_user_session
    end

    it 'assigns all messages to @messages' do
      get :messages_page, id: @experiment, page: '2'

      expect(Message).to have_received(:where).with(:message_generating_id => @experiment.id)
      expect(@experiment_messages).to have_received(:page).with('2')
      expect(@paged_messages).to have_received(:order).with('scheduled_date_time ASC')
    end
  end
end
