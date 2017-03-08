FactoryGirl.define do
  factory :website do
    name "Website"
    sequence :url do |n|
      "url-#{n}@example.com"
    end
  end
  
  factory :invalid_website, parent: :website do
    url nil
  end
end