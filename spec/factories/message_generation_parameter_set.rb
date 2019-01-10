FactoryBot.define do
  factory :message_generation_parameter_set do
    association :message_generating, factory: :experiment
    social_network_choices ['facebook']
    medium_choices ['ad']
    image_present_choices :no_messages
    number_of_cycles 5
    number_of_messages_per_social_network 1
    number_of_days_between_posting 1
  end

  factory :invalid_message_generation_parameter_set, parent: :message_generation_parameter_set do
    number_of_cycles nil
    number_of_messages_per_social_network nil
  end
end