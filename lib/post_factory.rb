# TODO: This entire class needs unit tests

class PostFactory
  def create_posts_for(experiment)
    # Destroy all existing posts for this experiment
    experiment.reload
    experiment.posts.destroy_all
    
    [:twitter, :facebook, :google].each do |platform|
      post_templates_for_platform = experiment.post_templates.select { |post_template| post_template.social_media_specification.platform == platform }.shuffle
      create_posts_from_post_templates(experiment, post_templates_for_platform)
    end
  end
  
  def create_posts_from_post_templates(experiment, post_templates)
    continue = true

    while continue
      post_templates.each do |post_template|
        post = Post.new
        post.experiment = experiment
        post.post_template = post_template
        post.content = post_template.content
        
        # Use up all the images
        if !post_template.image_pool.nil? && post_template.image_pool.length > 0
          post.content[:image] = post_template.image_pool[0]
          post_template.image_pool.shift
        end
        
        post.save
        # NOTE: The campaign URL needs the persisted ID, so we can only generate the campaign URL after persisting
        post.content[:campaign_url] = TrackingUrl.campaign_url(post)
        post.save
      end
    
      post_templates = post_templates.select{ |post_template| post_template.image_pool.length > 0 }
      continue = false if post_templates.length == 0
    end
  end
end
