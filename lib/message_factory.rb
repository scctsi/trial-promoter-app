class MessageFactory
  attr_reader :social_media_profile_picker

  def initialize(social_media_profile_picker)
    @social_media_profile_picker = social_media_profile_picker
  end

  def create(experiment)
    # Initial setup
    message_constructor = MessageConstructor.new
    number_of_cycles = experiment.message_generation_parameter_set.number_of_cycles
    platforms = experiment.message_generation_parameter_set.social_network_choices
    mediums = experiment.message_generation_parameter_set.medium_choices
    message_templates = MessageTemplate.belonging_to(experiment)
    posting_times = experiment.posting_times_as_datetimes
    total_count = experiment.message_generation_parameter_set.expected_generated_message_count(message_templates.count)
    message_index = 1
    publish_date = experiment.message_distribution_start_date
    
    # experiment.reload
    # experiment.messages.destroy_all

    number_of_cycles.times do |cycle_index|
      platforms.each do |platform|
        mediums.each do |medium|
          message_templates.each do |message_template|
            message = message_constructor.construct(experiment, message_template, platform, medium)
            message.save
            Pusher['progress'].trigger('progress', {:value => message_index, :total => total_count, :event => 'Message generated'})
            message_index += 1            
          end
        end
      end
    end

    # experiment.message_generation_parameter_set.social_network_choices.each do |social_network|
    #   message_templates_for_social_network = message_templates.select{ |message_template| message_template.platform == social_network }
    #   experiment.message_generation_parameter_set.medium_choices.each do |medium|
    #     (0...experiment.message_generation_parameter_set.period_in_days).each do |day|
    #       posting_times = experiment.posting_times_as_datetimes
    #       experiment.message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
    #         message_template = message_templates_for_social_network.sample
    #         website = tag_matcher.match(websites_belonging_to_experiment, message_template.tag_list).sample
    #         message = message_constructor.construct(experiment, message_template, website, medium)
    #         message.save
    #         generated_message_index += 1
    #       end
          
    #       generated_message_publish_date += 1.day
    #     end
    #   end
    # end

    # # Pick the social media profile on which to send out each message
    # experiment.messages.all.each do |message|
    #   message.social_media_profile = social_media_profile_picker.pick(experiment.social_media_profiles.to_a, message)
    #   message.save
    # end

    # # If we need to add images
    # include_images = true if experiment.message_generation_parameter_set.image_present_choices.include?(:with)
    # if include_images
    #   attach_images(experiment, experiment.messages)
    # end
  end

  def attach_images(experiment, messages)
    images_belonging_to_experiment = Image.belonging_to(experiment).to_a
    include_image = false

    messages.all.each do |message|
      if include_image || message.message_template.platform == :instagram
        image = tag_matcher.match(images_belonging_to_experiment, message.message_template.tag_list).sample
        message.image_present = :with
        message.image = image
      else
        message.image_present = :without
      end
      message.save

      # EXACTLY equal distribution
      include_image = !include_image
    end
  end
end

