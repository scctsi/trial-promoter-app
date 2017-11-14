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

  def get_posts(page_id)
    return @graph.get_object(page_id, fields: ['posts'])
  end
  
  def get_post_comments(post_id)
  end

  def get_comments(page_id)
    get_posts(page_id)
    all_posts = @graph.get_connections(page_id,"posts")
    begin
        all_posts.each do |fb_post|
          all_comments = @graph.get_connections(fb_post["id"], "comments", filter: 'stream')
          begin
            all_comments.each do |comment|
              make_comment = Comment.find_or_create_by(social_media_comment_id: comment["id"]) do |new_comment|
                new_comment.commentator_username = comment["from"]["name"],
                new_comment.commentator_id = comment["from"]["id"],  
                new_comment.comment_text = comment["message"]
              end
              make_comment.comment_date = make_comment["created_time"]
              make_comment.message = Message.find_by_published_text(fb_post["message"].squish)
              
              make_comment.save
            end
            all_comments = all_comments.next_page
          end while all_comments != nil
        end
        all_posts = all_posts.next_page
    end while all_posts != nil
  end
end