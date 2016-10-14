FactoryGirl.define do
  factory :website do
    title "Website"
    url "http://www.website.com/"
  end
  
  factory :invalid_website, parent: :website do
    title nil
    url nil
  end
end