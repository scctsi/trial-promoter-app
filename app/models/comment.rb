# == Schema Information
#
# Table name: comments
#
#  id                      :integer          not null, primary key
#  comment_date            :datetime
#  comment_text            :text
#  commentator_username    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  toxicity_score          :string
#  message_id              :integer
#  social_media_comment_id :string
#  commentator_id          :string
#

class Comment < ActiveRecord::Base
  acts_as_taggable_on :codes

  belongs_to :message

  def self.process(filepath)
    comments_spreadsheet = ExcelFileReader.new.read(filepath, true) if filepath.ends_with?('.xlsx') 

    # Only get messages that were actually published
    messages = Message.where(publish_status: :published_to_social_network)
    # Delete comments to avoid repeats from being saved
    # TODO fix this so it only deletes comments associated with the given experiment
    Comment.destroy_all
    message_index = comments_spreadsheet[0].index("Message")
    comment_index = comments_spreadsheet[0].index("Comment")
    comment_date_index = comments_spreadsheet[0].index("Date of Comment")
    comment_username_index = comments_spreadsheet[0].index("Commentator Username")

    messages.each do |message|  
      if !message.buffer_update.nil? 
        published_text = message.buffer_update.published_text.squish
        comments_spreadsheet.each do |comments_row| 
          #some comments have a newline/ space/ carriage return character in the message text that needs to be removed
          clean_message = comments_row[message_index].squish
          if published_text.include?(clean_message) 
            message.comments << Comment.create(comment_text: comments_row[comment_index], comment_date: comments_row[comment_date_index], commentator_username: comments_row[comment_username_index])
          end
        end
        message.save
      end
    end
  end
  
  def save_toxicity_score
    return if !toxicity_score.nil?
    self.toxicity_score = PerspectiveClient.calculate_toxicity_score(comment_text)
    
    save
  end
end
