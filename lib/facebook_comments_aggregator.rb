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

  def get_posts
    return @graph.get_object(object_id, fields: ['posts'])
  end

  def get_comments
    all_posts = @graph.get_connections("me","posts")

    begin
      CSV.open("facebook_ads_comments.csv", :write_headers => true, :headers => ["Message Date", "Message Id", "Message", "Comment", "Date of Comment", "Commentator Username"]) do |csv|
        all_posts.each do |fb_post|

          all_comments = @graph.get_connections(fb_post["id"], "comments", filter: 'stream')
          begin
            all_comments.each do |c|
              csv << [ fb_post["created_time"], fb_post["id"], fb_post["message"], c["created_time"], c["from"]["name"], c["message"] ]
            end
            all_comments = all_comments.next_page
          end while all_comments != nil
        end
        all_posts = all_posts.next_page
      end
    end while all_posts != nil
  end
end