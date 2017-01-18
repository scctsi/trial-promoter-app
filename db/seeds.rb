# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

if Hashtag.count == 0
  CSV.foreach("#{Rails.root}/db/seed_files/healthcare-hashtags-diseases.csv") do |row|
    begin
      Hashtag.create!(phrase: row[0])
    rescue ActiveRecord::RecordInvalid => e
      throw e if e.message != 'Validation failed: Phrase has already been taken'
    end
  end
end

user_attributes = [
  { email: "default@sc-ctsi.org", password: "default321", password_confirmation: "default321", role: 'user'  },
  { email: "admin@sc-ctsi.org", password: "dic101!!", password_confirmation: "dic101!!", role: 'administrator'  },
  { email: "read@sc-ctsi.org", password: "read321", password_confirmation: "read321", role: 'read_only'  },
  { email: "stat@sc-ctsi.org", password: "stat321", password_confirmation: "stat321", role: 'statistician'  },
]

user_attributes.each do |attributes|
  user = User.find_by(email: attributes[:email])
  User.create(attributes) if user.nil?
end