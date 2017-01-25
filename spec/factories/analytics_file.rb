FactoryGirl.define do
  factory :analytics_file do
    association :social_media_profile
    association :message_generating, factory: :experiment
    required_upload_date Faker::Date.forward(14)
  end
end

