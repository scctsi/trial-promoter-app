FactoryGirl.define do
  factory :posting_time do
    create
    experiment_id 1
    posting_times Array.new(3, DateTime.now)
  end

  factory :invalid_posting_time do
  end
end