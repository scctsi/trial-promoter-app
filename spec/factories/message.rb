FactoryGirl.define do
  factory :message do
    clinical_trial
    message_template
    content 'Content'
    status :new
  end
end