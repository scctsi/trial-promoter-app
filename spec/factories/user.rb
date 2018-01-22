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

  factory :statistician, parent: :user do
    role 'statistician'
  end

  factory :read_only, parent: :user do
    role 'read_only'
  end
end