class MessageFactory
  attr_reader :social_media_profile_picker

  def initialize(social_media_profile_picker)
    @social_media_profile_picker = social_media_profile_picker
  end

  def create(experiment)
    # Destroy all existing messages for this experiment
    experiment.reload
    experiment.messages.destroy_all

    # Initial setup
    parameters = get_message_generation_parameters(experiment)
    message_index = 1
    message_for_day_index = 1
    publish_date = experiment.message_distribution_start_date

    parameters[:number_of_cycles].times do |cycle_index|
      parameters[:platforms].each do |platform|
        parameters[:mediums].each do |medium|
          parameters[:message_templates].each do |message_template|
            picked_social_media_profile = @social_media_profile_picker.pick(parameters[:social_media_profiles], platform, medium)
            message = parameters[:message_constructor].construct(experiment, message_template, platform, medium, picked_social_media_profile, publish_date, parameters[:posting_times][platform][0])
            message.save
            Pusher['progress'].trigger('progress', {:value => message_index, :total => parameters[:total_count], :event => 'Message generated'})
            message_index += 1
            message_for_day_index += 1
            if message_for_day_index > parameters[:number_of_messages_per_day]
              publish_date += 1.day
              message_for_day_index = 1
            end
          end
        end
      end
    end

    # # Pick the social media profile on which to send out each message
    # experiment.messages.all.each do |message|
    #   message.social_media_profile = social_media_profile_picker.pick(experiment.social_media_profiles.to_a, message)
    #   message.save
    # end

    select_images(experiment.messages)
  end

  def select_images(messages)
    messages.all.each do |message|
      message.image_present = :with
      message.image_id = message.message_template.image_pool.sample
      message.save
    end
  end
  
  def get_message_generation_parameters(experiment)
    parameters = {}

    parameters[:message_constructor] = MessageConstructor.new
    parameters[:number_of_cycles] = experiment.message_generation_parameter_set.number_of_cycles
    parameters[:number_of_messages_per_day] = experiment.message_generation_parameter_set.number_of_messages_per_social_network
    parameters[:platforms] = experiment.message_generation_parameter_set.social_network_choices
    parameters[:mediums] = experiment.message_generation_parameter_set.medium_choices
    parameters[:message_templates] = MessageTemplate.belonging_to(experiment)
    parameters[:posting_times] = experiment.posting_times_as_datetimes
    parameters[:total_count] = experiment.message_generation_parameter_set.expected_generated_message_count(parameters[:message_templates].count)
    parameters[:social_media_profiles] = experiment.social_media_profiles

    parameters
  end
end

