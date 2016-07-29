FactoryGirl.define do
  factory :message_template do
    content "Some content for Twitter with a {parameter}"
    platform :twitter
  end
end