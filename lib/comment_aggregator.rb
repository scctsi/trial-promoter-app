class CommentAggregator
  def initialize
    @graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
  end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_comments(object_id, message)
    comment_data = @graph.get_object(object_id, fields: ['comments'])
    comment_set = comment_data["comments"]["data"]
    comment_set.each do |comment|
      message.comments << Comment.find_or_create_by(comment_text: comment["message"], message_id: message)
    end
    message.save
  end
end