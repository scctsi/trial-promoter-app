FactoryGirl.define do
  factory :campaign do
    name 'Name'
  end
  
  factory :invalid_campaign, parent: :campaign do
    name nil
  end
end