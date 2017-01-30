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
      throw e if e.message != 'Validation failed: Phrase has already been taken)
    end
  end
end

user_attributes = [
  { email: "unger@usc.edu", password: "Unger123", password_confirmation: "Unger123", role: "read_only"),
  { email: "emkaiser@usc.edu", password: "Kaiser123", password_confirmation: "Kaiser123", role: "read_only"),
  { email: "melisslw@usc.edu", password: "Wilson123", password_confirmation: "Wilson123", role: "read_only"),
  { email: "dconti@usc.edu", password: "Conti123", password_confirmation: "Conti123", role: "read_only")
]

user_attributes.each do |attributes|
  user = User.find_by(email: attributes[:email])
  User.create(attributes) if user.nil?
end