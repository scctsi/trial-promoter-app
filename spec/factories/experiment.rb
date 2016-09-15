FactoryGirl.define do
  factory :experiment do
    name 'Name'
  end
  
  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end