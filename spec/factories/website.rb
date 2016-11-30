FactoryGirl.define do
  factory :website do
    name "Website"
    url "http://www.website.com/"
  end
  
  factory :invalid_website, parent: :website do
    url nil
  end
end