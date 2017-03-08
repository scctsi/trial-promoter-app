FactoryGirl.define do
  factory :experiment do
    name 'Name'
    message_distribution_start_date '01-01-2017'
  end

  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end