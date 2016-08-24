FactoryGirl.define do
  factory :message_template do
    content "Some content for Twitter with a {parameter}"
    platform :twitter
  end
  
  factory :invalid_message_template, parent: :message_template do
    content nil
  end
end