FactoryGirl.define do
  factory :experiment do
    name 'Name'
    start_date '01-01-2017'
    end_date '01-02-2017'
    transient do
      social_media_profiles_count 1
    end

    after(:build) do |experiment, evaluator|
      create(:message_generation_parameter_set, social_network_choices: [:facebook], medium_choices: [:ad], message_generating: experiment)
    end

    after(:build) do |experiment, evaluator|
      create_list(:social_media_profile, evaluator.social_media_profiles_count, experiments: [experiment], allowed_mediums: [:ad], platform: :facebook)
    end
  end

  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end