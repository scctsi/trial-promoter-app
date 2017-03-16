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
    publish_date = experiment.message_distribution_start_date

    parameters[:number_of_cycles].times do |cycle_index|
      message_template_index = 0
      shuffled_message_templates = parameters[:message_templates].shuffle
      while message_template_index < shuffled_message_templates.count
        parameters[:number_of_messages_per_day].times do |message_index_for_day|
          message_template = shuffled_message_templates[message_template_index]
          # TODO: Select hashtags here!
          random_image_id = message_template.image_pool.sample
          message_template_index += 1
          parameters[:platforms].each do |platform|
            parameters[:mediums].each do |medium|
              next if platform == :instagram && medium == :organic # Do not create organic instagram messages
              picked_social_media_profile = @social_media_profile_picker.pick(parameters[:social_media_profiles], platform, medium)
              message = parameters[:message_constructor].construct(experiment, message_template, platform, medium, picked_social_media_profile, publish_date, parameters[:posting_times][platform][message_index_for_day], message_template.hashtags)
              message.image_present = :with
              message.image_id = random_image_id
              message.save
              Pusher['progress'].trigger('progress', {:value => message_index, :total => parameters[:total_count], :event => 'Message generated'})
              message_index += 1
            end
          end
        end
        publish_date += 1.day
      end
    end
  end

  def get_message_generation_parameters(experiment)
    parameters = {}

    parameters[:message_constructor] = MessageConstructor.new
    parameters[:number_of_cycles] = experiment.message_generation_parameter_set.number_of_cycles
    parameters[:number_of_messages_per_day] = experiment.message_generation_parameter_set.number_of_messages_per_social_network
    parameters[:platforms] = experiment.message_generation_parameter_set.social_network_choices
    parameters[:mediums] = experiment.message_generation_parameter_set.medium_choices
    parameters[:message_templates] = MessageTemplate.belonging_to(experiment).to_a
    parameters[:posting_times] = experiment.posting_times_as_datetimes
    parameters[:total_count] = experiment.message_generation_parameter_set.expected_generated_message_count(parameters[:message_templates].count)
    parameters[:social_media_profiles] = experiment.social_media_profiles

    parameters
  end
end

