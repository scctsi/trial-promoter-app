FactoryGirl.define do
  factory :experiment do
    name 'Name'
    start_date '01-01-2017'
    end_date '01-02-2017'
  end
  
  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end