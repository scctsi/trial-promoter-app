# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
#  message_date         :date
#  content              :text
#  comment_date         :date
#  comment_text         :text
#  commentator_username :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  message_id           :string
#  toxicity_score       :string
#  url                  :string
#

class Comment < ActiveRecord::Base
  belongs_to :message

  def process
    content = ExcelFileReader.new.read(url) if url.ends_with?('.xlsx')
    parseable_data = CommentsDataParser.convert_to_parseable_data(content)
    parsed_data = CommentsDataParser.parse(parseable_data)
    CommentsDataParser.store(parsed_data)
  end
end
