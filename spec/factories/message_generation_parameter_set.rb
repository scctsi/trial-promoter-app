FactoryGirl.define do
  factory :message_generation_parameter_set do
    selected_message_templates_tag 'experiment'
    period_in_days 5
    number_of_messages_per_social_network 1
  end
  
  factory :invalid_message_generation_parameter_set, parent: :message_generation_parameter_set do
  end
end