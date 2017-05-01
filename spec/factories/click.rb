FactoryGirl.define do
  factory :click do
    click_meter_tracking_link

    trait :wednesday_clicks do
      click_time "26 April 2017 19:21"
    end

    trait :tuesday_clicks do
      click_time "25 April 2017 17:38"
    end

    trait :monday_clicks do
      click_time "24 April 2017 00:01"
    end

    trait :sunday_clicks do
      click_time "23 April 2017"
    end
  end
end

