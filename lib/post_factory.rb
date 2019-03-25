# TODO: This entire class needs unit tests

class PostFactory
  def create_posts_for(experiment)
    generated_posts = []
    
    # Destroy all existing posts for this experiment
    experiment.reload
    experiment.posts.destroy_all
    
    shuffled_post_templates = experiment.post_templates.shuffle
    continue = true

    while continue        
      shuffled_post_templates.each do |post_template|
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
      
      shuffled_post_templates = shuffled_post_templates.select{ |post_template| post_template.image_pool.length > 0 }
      continue = false if shuffled_post_templates.length == 0
    end
    
    return generated_posts
  end
  
  # Initial setup
  #   parameters = get_message_generation_parameters(experiment)
  #   message_index = 1
  #   publish_date = experiment.message_distribution_start_date

  #   parameters[:number_of_cycles].times do |cycle_index|
  #     message_template_index = 0
  #     shuffled_message_templates = parameters[:message_templates].shuffle
  #     while message_template_index < shuffled_message_templates.count
  #       parameters[:number_of_messages_per_day].times do |message_index_for_day|
  #         message_template = shuffled_message_templates[message_template_index]
  #         # The message contructor randomly selects a hashtag.
  #         # However since we require that the hashtag be the same across all the messages generated from this template, we select the hashtag here and put it in an array (the message constructor requires this to be an array).
  #         if !message_template.hashtags.nil? && message_template.hashtags.length > 0
  #           randomly_selected_hashtags = [message_template.hashtags.sample]
  #         else
  #           randomly_selected_hashtags = nil
  #         end
  #         random_image_id = message_template.image_pool.sample
  #         message_template_index += 1
  #         parameters[:platforms].each do |platform|
  #           parameters[:mediums].each do |medium|
  #             if !(platform == :instagram && medium == :organic) # Do not create organic instagram messages
  #               picked_social_media_profile = @social_media_profile_picker.pick(parameters[:social_media_profiles], platform, medium)
  #               message = parameters[:message_constructor].construct(experiment, message_template, platform, medium, picked_social_media_profile, publish_date, parameters[:posting_times][platform][message_index_for_day], randomly_selected_hashtags)
  #               message.image_present = :with
  #               message.image_id = random_image_id
  #               message.save
  #               message.reload
  #               parameters[:tracking_link_client].create_click_meter_tracking_link(experiment, message, experiment.click_meter_group_id, experiment.click_meter_domain_id)
  #               message.save
  #               throttle(9)
  #               Pusher['progress'].trigger('progress', {:value => message_index / 2, :total => parameters[:total_count], :event => 'Message generated'})
  #               message_index += 1
  #               generated_messages << message
  #             end
  #           end
  #         end
  #       end
  #       publish_date += parameters[:number_of_days_between_posting].day
  #     end
  #   end
    
  #   # Update {url} variables in all the messages
  #   generated_messages.each do |message|
  #     parameters[:tracking_link_client].update_tracking_link(experiment, message.click_meter_tracking_link)
  #     throttle(9)
  #     parameters[:message_constructor].replace_url_variable(message, message.click_meter_tracking_link.tracking_url)
  #     message.save
  #     Pusher['progress'].trigger('progress', {:value => message_index / 2, :total => parameters[:total_count], :event => 'Message generated'})
  #     message_index += 1
  #   end
  # end

  # def get_message_generation_parameters(experiment)
  #   parameters = {}

  #   parameters[:message_constructor] = MessageConstructor.new
  #   parameters[:number_of_cycles] = experiment.message_generation_parameter_set.number_of_cycles
  #   parameters[:number_of_messages_per_day] = experiment.message_generation_parameter_set.number_of_messages_per_social_network
  #   parameters[:number_of_days_between_posting] = experiment.message_generation_parameter_set.number_of_days_between_posting
  #   # TODO: Test the next line
  #   parameters[:number_of_days_between_posting] = 1 if parameters[:number_of_days_between_posting].nil?
  #   parameters[:platforms] = experiment.message_generation_parameter_set.social_network_choices
  #   parameters[:mediums] = experiment.message_generation_parameter_set.medium_choices
  #   parameters[:message_templates] = MessageTemplate.belonging_to(experiment).to_a
  #   parameters[:posting_times] = experiment.posting_times
  #   parameters[:total_count] = experiment.message_generation_parameter_set.expected_generated_message_count(parameters[:message_templates].count)
  #   parameters[:social_media_profiles] = experiment.social_media_profiles
  #   if experiment.use_click_meter
  #     parameters[:tracking_link_client] = ClickMeterClient
  #   else
  #     parameters[:tracking_link_client] = BasicTrackingLinkClient
  #   end
    
  #   parameters
  # end
  
  # def throttle(operations_per_second)
  #   Kernel.sleep(1.0 / operations_per_second) if !Rails.env.test?
  # end
end

