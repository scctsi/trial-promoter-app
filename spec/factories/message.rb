FactoryGirl.define do
  factory :message do
    clinical_trial
    message_template
    text 'Text'
    status :new
  end
end