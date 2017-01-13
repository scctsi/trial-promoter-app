class MessageFactory
  attr_reader :tag_matcher
  
  def initialize(tag_matcher)
    @tag_matcher = tag_matcher
  end
  
  def create(message_generating_instance)
    message_generating_instance.reload
    message_generating_instance.messages.destroy_all

    message_constructor = MessageConstructor.new
    message_templates = MessageTemplate.belonging_to(message_generating_instance)

    message_generating_instance.message_generation_parameter_set.social_network_choices.each do |social_network|
      message_templates_for_social_network = message_templates.select{ |message_template| message_template.platform == social_network }
      message_generating_instance.message_generation_parameter_set.medium_choices.each do |medium|
        (0...message_generating_instance.message_generation_parameter_set.period_in_days).each do |day|
          message_generating_instance.message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
            message_template = message_templates_for_social_network.sample
            website = tag_matcher.match(Website, message_template.tag_list).sample
            message = message_constructor.construct(message_generating_instance, message_template, website, medium)
            message.save
          end
        end
      end
    end
    
    # If we need to add images
    include_images = true if message_generating_instance.message_generation_parameter_set.image_present_choices.include?(:with)
    if include_images
      attach_images(message_generating_instance.messages, message_generating_instance.message_generation_parameter_set.image_present_distribution)
    end
  end
  
  def attach_images(messages, distribution=:equal)
    include_image = false
    
    messages.all.each do |message|
      if include_image
        image = tag_matcher.match(Image, message.message_template.tag_list).sample
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

