FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    role 'user'
  end

  factory :administrator, parent: :user do
    role 'administrator'
  end
end