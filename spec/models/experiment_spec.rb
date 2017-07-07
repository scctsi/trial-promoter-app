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
  it { is_expected.to have_and_belong_to_many :social_media_profiles }

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
end
