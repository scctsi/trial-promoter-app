FactoryBot.define do
  factory :message_template do
    content "Some content for Twitter with a {parameter}"
    platforms [:twitter]
    promoted_website_url 'http://example.com'
  end
  
  factory :invalid_message_template, parent: :message_template do
    content nil
  end
end