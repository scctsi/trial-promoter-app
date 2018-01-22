FactoryBot.define do
  factory :image do
    sequence :url do |n|
      "http://www.image-#{n}.com"
    end
    sequence :original_filename do |n|
      "http://www.filename-#{n}.com"
    end
  end
end