FactoryGirl.define do
  factory :message do
    clinical_trial
    message_template
    association :message_generating, factory: :experiment
    content 'Content'
    status :new
  end
end