# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  start_date                      :datetime
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'rails_helper'

RSpec.describe Experiment, type: :model do
  before do
    time_now = Time.new(2017, 01, 01, 0, 0, 0, "+00:00")
    allow(Time).to receive(:now).and_return(time_now )
  end

  it { is_expected.to validate_presence_of :name }

  it { is_expected.to have_one(:message_generation_parameter_set) }
  it { is_expected.to accept_nested_attributes_for(:message_generation_parameter_set) }
  it { is_expected.to have_many(:messages) }
  it { is_expected.to have_and_belong_to_many :social_media_profiles }

  it 'disables message generation when distribution start date is less than 24 hours from current time' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 23, 59, 0,  "+00:00") )

    expect(experiment.disable_message_generation?).to be true
  end

  it 'does not disable message generation when distribution start date is more than 24 hours from current time' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 03, 0, 0, 0, "+00:00") )

    expect(experiment.disable_message_generation?).to be false
  end

  it 'will not determine whether to disable message generation when distribution start date is not present' do
    experiment = create(:experiment)

    expect(experiment.disable_message_generation?).to be false
  end

  it 'parameterizes id and name together' do
    experiment = create(:experiment, name: 'TCORS 2')

    expect(experiment.to_param).to eq("#{experiment.id}-#{experiment.name.parameterize}")
  end

  it 'creates messages using a message factory' do
    experiment = create(:experiment)
    allow(experiment).to receive(:create_messages).and_call_original
    message_factory = MessageFactory.new(TagMatcher.new)
    allow(message_factory).to receive(:create).with(experiment)
    allow(MessageFactory).to receive(:new).and_return(message_factory)

    experiment.create_messages

    expect(MessageFactory).to have_received(:new)
    expect(message_factory).to have_received(:create).with(experiment)
  end
end
