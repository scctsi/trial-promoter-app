FactoryGirl.define do
  factory :click do
    click_meter_tracking_link

    trait :wednesday_clicks do
      click_time
    end

    trait :tuesday_clicks do
      sequence :click_time do |n|
        "25 April 2017 21:#{n}5"
      end
    end

    trait :monday_clicks do
      sequence :click_time do |n|
        "24 April 2017 00:#{n}1"
      end
    end

    trait :sunday_clicks do
      sequence :click_time do |n|
        "23 April 2017 04:5#{n}"
      end
    end
  end
end

