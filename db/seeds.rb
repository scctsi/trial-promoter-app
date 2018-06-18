# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'net/http'
require 'roo'

comments = Comment.select{ |comment| comment.message.platform == :twitter || comment.message.platform == :instagram }
comments.each{ |comment| comment.destroy }

CSV.parse(Net::HTTP.get(URI.parse('https://s3-us-west-1.amazonaws.com/scctsi-tp-production/1-tcors/comments/instagram_comments.csv'))) do |row|
  comment = Comment.new(message_id: row[0], comment_date: row[2], comment_text: row[1], commentator_username: row[3])
  if !(row[0].nil?)
    comment.save
    message = Message.find(row[0])
    message.comments << comment
    message.save
  end
end

message_id_sheet = Roo::Spreadsheet.open('https://s3-us-west-1.amazonaws.com/scctsi-tp-production/1-tcors/comments/message_ids_for_twitter_ad_comments.xlsx')
message_ids = message_id_sheet.sheet(0)
for index in (2..message_ids.last_row)
  comment = Comment.new(message_id: message_ids.cell(index, 1), comment_date: message_ids.cell(index, 3), comment_text: message_ids.cell(index, 2), commentator_username: message_ids.cell(index, 4))
  if !(comment.message_id.nil?)
    comment.save
    message = Message.find(comment.message_id)
    message.comments << comment
    message.save
  end
end
