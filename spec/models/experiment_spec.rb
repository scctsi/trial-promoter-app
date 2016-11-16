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
  it { is_expected.to validate_presence_of :name }
  
  it { is_expected.to have_one(:message_generation_parameter_set) }
  it { is_expected.to have_and_belong_to_many(:clinical_trials) }
  it { is_expected.to accept_nested_attributes_for(:message_generation_parameter_set) }
  
  it 'parameterizes id and name together' do
    experiment = create(:experiment, name: 'TCORS 2')
    
    expect(experiment.to_param).to eq("#{experiment.id}-#{experiment.name.parameterize}")
  end
end
