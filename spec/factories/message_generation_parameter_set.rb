FactoryGirl.define do
  factory :message_generation_parameter_set do
    association :message_generating, factory: :experiment
    social_network_choices ['facebook']
    medium_choices ['ad']
    image_present_choices :no_messages
    number_of_cycles 5
    number_of_messages_per_social_network 1
  end

  factory :invalid_message_generation_parameter_set, parent: :message_generation_parameter_set do
    period_in_days nil
    number_of_messages_per_social_network nil
  end
end