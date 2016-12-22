FactoryGirl.define do
  factory :message do
    message_template
    association :message_generating, factory: :experiment
    association :promotable, factory: :website
    content 'Content'
    publish_status :new
  end
end