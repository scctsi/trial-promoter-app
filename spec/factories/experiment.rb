FactoryBot.define do
  factory :experiment do
    name 'Name'
    message_distribution_start_date DateTime.new(2017, 1, 1, 12, 0, 0)
  end

  factory :invalid_experiment, parent: :experiment do
    name nil
  end
end