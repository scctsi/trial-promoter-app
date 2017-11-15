require "csv"

class FacebookCommentsAggregator
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    @graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
  end

  def get_user_object
    return @graph.get_connections("me", "accounts")
  end

  def get_paginated_posts(page_id)
    return @graph.get_connections(page_id, 'posts')
  end
  
  def get_post_comments(post_id, published_text)
    post_comments = @graph.get_connections(post_id, "comments", filter: 'stream')
    loop do
      post_comments.each do |comment|
        make_comment = Comment.find_or_create_by(social_media_comment_id: comment["id"]) do |new_comment|
          new_comment.commentator_username = comment["from"]["name"],
          new_comment.commentator_id = comment["from"]["id"],  
          new_comment.comment_text = comment["message"]
        end
        make_comment.comment_date = make_comment["created_time"]
        make_comment.message = Message.find_by_published_text(published_text.squish)
        
        make_comment.save
      end
      post_comments = post_comments.next_page
      break if post_comments == nil
    end
  end

  def get_comments(page_id)
    paginated_posts = get_paginated_posts(page_id)
    loop do
      paginated_posts.each do |fb_post|
        get_post_comments(fb_post["id"], fb_post["message"]) 
      end
      paginated_posts = paginated_posts.next_page
      break if paginated_posts == nil
    end
  end
end