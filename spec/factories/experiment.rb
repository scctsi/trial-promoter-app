FactoryGirl.define do
  factory :experiment do
    name 'Name'
    message_distribution_start_date '01-01-2017'
    end_date '01-02-2017'
    transient do
      social_media_profiles_count 1
    end
  end

  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end