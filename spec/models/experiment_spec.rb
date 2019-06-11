# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  twitter_posting_times           :text
#  facebook_posting_times          :text
#  instagram_posting_times         :text
#  click_meter_group_id            :integer
#  click_meter_domain_id           :integer
#  comment_codes                   :text
#  image_codes                     :text
#  ip_exclusion_list               :text
#

require 'rails_helper'

RSpec.describe Experiment, type: :model do
  before do
    time_now = Time.new(2017, 01, 01, 0, 0, 0, "+00:00")
    allow(Time).to receive(:now).and_return(time_now)
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :message_distribution_start_date }

  it { is_expected.to have_one(:message_generation_parameter_set) }
  it { is_expected.to accept_nested_attributes_for(:message_generation_parameter_set) }
  it { is_expected.to have_one(:data_dictionary) }
  it { is_expected.to have_many(:messages) }
  it { is_expected.to have_many(:analytics_files) }
  it { is_expected.to have_many(:modifications) } 
  it { is_expected.to have_and_belong_to_many :social_media_profiles }
  it { is_expected.to serialize(:image_codes).as(Array) }
  it { is_expected.to serialize(:comment_codes).as(Array) }
  it { is_expected.to have_and_belong_to_many(:users) }
  it { is_expected.to have_many(:post_templates) }
  it { is_expected.to have_many(:posts) }
  it { is_expected.to have_many(:split_tests) }

  it 'returns an array of all possible times in a day' do 
    expect(Experiment.allowed_times.count).to be(12 * 60 * 2)
  end

  it 'includes various times of the day in the array of all possible times' do
    expect(Experiment.allowed_times).to include('12:30 AM', '3:04 AM', '1:30 PM')
  end

  it 'disables message generation when distribution start date is after the current date' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 0,  "+00:00") )

    expect(experiment.disable_message_generation?).to be true
  end

  it 'does not disable message generation when distribution start date is before the current date' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 1, "+00:00") )

    expect(experiment.disable_message_generation?).to be false
  end

  it 'disables imports when there are messages present' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 0,  "+00:00") )
    experiment.messages << build(:message)
    experiment.save
    
    expect(experiment.disable_import?).to be true
  end

  it 'does not disable message generation when distribution start date is before the current date' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 0,  "+00:00") )

    expect(experiment.disable_import?).to be false
  end

  it 'parameterizes id and name together' do
    experiment = create(:experiment, name: 'TCORS 2')

    expect(experiment.to_param).to eq("#{experiment.id}-#{experiment.name.parameterize}")
  end

  it 'creates messages using a message factory' do
    experiment = build(:experiment)
    allow(experiment).to receive(:create_messages).and_call_original
    message_factory = double('message_factory')
    allow(message_factory).to receive(:create).with(experiment)
    allow(MessageFactory).to receive(:new).and_return(message_factory)

    experiment.create_messages

    expect(MessageFactory).to have_received(:new)
    expect(message_factory).to have_received(:create).with(experiment)
  end

  it 'iterates over all the days in the experiment' do
    experiment = build(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 0, 0, 0, "+00:00"))
    allow(experiment).to receive(:end_date).and_return(experiment.message_distribution_start_date + 10.days)
    number_of_days = 0

    experiment.each_day do |day|
      expect(day).to be >= experiment.message_distribution_start_date
      expect(day).to be <= experiment.end_date
      number_of_days += 1
    end
    expect(number_of_days).to be(11)
  end

  describe 'returning posting times' do
    before do
      @experiment = build(:experiment)
    end

    it 'returns a hash with platform key and an array of hashes containing the hour and minute values' do
      @experiment.twitter_posting_times = '12:30 AM,12:30 PM,05:10 AM,05:20 PM' 
      @experiment.facebook_posting_times = '12:30 AM,12:30 PM,05:10 AM' 
      @experiment.instagram_posting_times = '12:30 AM,12:30 PM,05:10 AM' 
      
      posting_times = @experiment.posting_times
      
      expect(posting_times.keys.count).to eq(3)
      twitter_posting_times = posting_times[:twitter]
      expect(twitter_posting_times.count).to eq(4)
      expect(twitter_posting_times[0][:hour]).to eq(0)
      expect(twitter_posting_times[0][:minute]).to eq(30)
      expect(twitter_posting_times[1][:hour]).to eq(12)
      expect(twitter_posting_times[1][:minute]).to eq(30)
      expect(twitter_posting_times[2][:hour]).to eq(5)
      expect(twitter_posting_times[2][:minute]).to eq(10)
      expect(twitter_posting_times[3][:hour]).to eq(17)
      expect(twitter_posting_times[3][:minute]).to eq(20)
    end
    
    it 'returns a hash with platform key and an empty array for missing platform times' do
      @experiment.twitter_posting_times = '12:30 AM,12:30 PM,05:10 AM' 
      @experiment.facebook_posting_times = '' 
      @experiment.instagram_posting_times = nil
      
      posting_times = @experiment.posting_times
      
      expect(posting_times.keys.count).to eq(3)
      expect(posting_times[:facebook]).to eq([])
      expect(posting_times[:instagram]).to eq([])
    end
  end
  
  it 'calculates the end date for the experiment' do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set)
    allow(experiment.message_generation_parameter_set).to receive(:length_of_experiment_in_days).and_return(10)
    
    expect(experiment.end_date).to eq(experiment.message_distribution_start_date + experiment.message_generation_parameter_set.length_of_experiment_in_days(10).days)
  end
  
  it 'returns a default timeline' do
    experiment = build(:experiment)
    allow(experiment).to receive(:end_date).and_return(experiment.message_distribution_start_date + 10.days)
    
    expect(experiment.timeline.events).to eq(Timeline.build_default_timeline(experiment).events)
  end
  
  it 'sets api key settings' do
    service_name = :click_meter
    key = 'fake_api_key'
    experiment = build(:experiment)
    
    experiment.set_api_key(service_name, key)
    experiment.reload
    
    expect(experiment.settings(:click_meter).api_key).to eq(key)
  end
  
  it 'returns nil for non-existant api key' do 
    experiment = build(:experiment)

    expect(experiment.settings(:click_meter).api_key).to eq(nil)
  end
  
  it 'sets api keys and api secrets settings for AWS' do
    key = 'fake_api_key'    
    secret_key = 'fake_secret_api_key'
    experiment = build(:experiment)
    
    experiment.set_aws_key(key, secret_key)
    experiment.reload
    
    expect(experiment.settings(:aws).access_key).to eq(key)
    expect(experiment.settings(:aws).secret_access_key).to eq(secret_key)
  end
  
  it 'sets api tokens and api secrets settings for Facebook' do
    token = 'fake_token'    
    ads_token = 'fake_ads_token'
    app_secret = 'fake_app_secret'
    experiment = build(:experiment)
    
    experiment.set_facebook_keys(token, ads_token, app_secret)
    experiment.reload
    
    expect(experiment.settings(:facebook).access_token).to eq(token)
    expect(experiment.settings(:facebook).ads_access_token).to eq(ads_token)
    expect(experiment.settings(:facebook).app_secret).to eq(app_secret)
  end
  
  it 'sets api tokens and api secrets settings for Twitter' do
    consumer_key = 'fake_api_key'    
    consumer_secret = 'fake_api_key_secret'    
    access_token = 'fake_access_token'
    access_token_secret = 'fake_token_secret'
    experiment = build(:experiment)
    
    experiment.set_twitter_keys(consumer_key, consumer_secret, access_token, access_token_secret)
    experiment.reload
    
    expect(experiment.settings(:twitter).consumer_key).to eq(consumer_key)
    expect(experiment.settings(:twitter).consumer_secret).to eq(consumer_secret)
    expect(experiment.settings(:twitter).access_token).to eq(access_token)
    expect(experiment.settings(:twitter).access_token_secret).to eq(access_token_secret)
  end
  
  it 'sets the google auth file' do
    auth_json_file = '{
  "type": "fake_account",
  "project_id": "fake",
  "private_key_id": "fake",
  "private_key": "-----BEGIN PRIVATE KEY-----fake/fake/fake=-----END PRIVATE KEY-----",
  "client_email": "fake",
  "client_id": "fake",
  "auth_uri": "https://fake/o/oauth2/auth",
  "token_uri": "https://fake/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://fake/oauth2/v1/certs",
  "client_x509_cert_url": "https://fake%40appspot.gserviceaccount.com"}'
    experiment = build(:experiment)
    
    experiment.set_google_api_key(auth_json_file)
    experiment.reload
    
    expect(experiment.settings(:google).auth_json_file).to eq(auth_json_file)
  end
  
  it 'finds an experiment by its param' do
    create(:experiment, name: 'experiment')

    experiment = Experiment.find_by_param(Experiment.first.to_param)

    expect(experiment).to eq(Experiment.first)
  end
  
  it 'returns false if the experiment does not have experiment variables' do
    experiment = build(:experiment)
  
    expect(experiment.has_experiment_variables?).to eq(false)
  end
  
  it 'returns true if the experiment has experiment variables' do
    experiment = create(:experiment, name: 'tcors')
    message_template = create(:message_template)
    message_template.experiment_list.add(experiment.to_param)
    message_template.experiment_variables = {'health' => 'turn it up to 11'}
    message_template.save

    expect(experiment.has_experiment_variables?).to eq(true)
  end
end
