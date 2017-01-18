FactoryGirl.define do
  factory :social_media_profile do
    service_id '1'
    service_username Faker.name
    platform :twitter
  end
end