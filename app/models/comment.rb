# == Schema Information
#
# Table name: comments
#
#  id                   :integer          not null, primary key
#  comment_date         :date
#  comment_text         :text
#  commentator_username :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  message_id           :string
#  toxicity_score       :string
#

class Comment < ActiveRecord::Base
  acts_as_taggable_on :codes

  belongs_to :message
  
  def process(filename)
    comments_spreadsheet = ExcelFileReader.new.read(filename) if filename.ends_with?('.xlsx') 
    messages = Message.all
    #delete comments to avoid repeats from being saved
    messages.each do |message|
      message.comments.destroy_all
    end
    message_index = comments_spreadsheet[0].index("Message")
    comment_index = comments_spreadsheet[0].index("Comment")
    comment_date_index = comments_spreadsheet[0].index("Date of Comment")
    comment_username_index = comments_spreadsheet[0].index("Commentator Username")
    orphan_comments = []
    messages.each do |message|  
      comments_spreadsheet.each do |comments_row| 
        #some comments have a newline character that needs to be removed
        clean_comment = comments_row[message_index].chomp
<<<<<<< HEAD
        orphan_comments << clean_comment
=======
>>>>>>> development
        if !message.buffer_update.nil? && message.buffer_update.published_text == clean_comment 
          message.comments << Comment.create(comment_text: comments_row[comment_index], comment_date: comments_row[comment_date_index], commentator_username: comments_row[comment_username_index])
          orphan_comments -= [clean_comment]
        end 
      end
      message.save
    end
    orphan_comments.each do |comment| 
      logger.debug { "The comment: " + comment + " could not find a matching message." }
    end
    messages.each{|m|  p m.comments }
  end
  
  def save_toxicity_score
    return if !toxicity_score.nil?
    self.toxicity_score = PerspectiveClient.calculate_toxicity_score(comment_text)
    
    save
  end
end
 