FactoryGirl.define do
  factory :utm_parameter_set do
    source 'twitter'
    medium 'feed'
    campaign 'trial-promoter'
  end
end