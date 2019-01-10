FactoryBot.define do
  factory :message do
    message_template
    association :message_generating, factory: :experiment
    content 'Content'
    platform :twitter
    promoted_website_url 'http://url.com/'
    publish_status :pending
  end
end