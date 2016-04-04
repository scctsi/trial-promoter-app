class MessageTemplatesController < ApplicationController
  def index
    @twitter_message_templates = MessageTemplate.where(:platform => 'twitter').order('cast(initial_id as integer)')
    @twitter_uscprofiles_message_templates = MessageTemplate.where(:platform => 'twitter_uscprofiles').order('cast(initial_id as integer)')
    @facebook_message_templates = MessageTemplate.where(:platform => 'facebook').order('cast(initial_id as integer)')
    @facebook_uscprofiles_message_templates = MessageTemplate.where(:platform => 'facebook_uscprofiles').order('cast(initial_id as integer)')
    @google_message_templates = MessageTemplate.where(:platform => 'google').order('cast(initial_id as integer)')
    @google_uscprofiles_message_templates = MessageTemplate.where(:platform => 'google_uscprofiles').order('cast(initial_id as integer)')
    @youtube_search_results_message_templates = MessageTemplate.where(:platform => 'youtube_search_results').order('cast(initial_id as integer)')
    @youtube_uscprofiles_message_templates = MessageTemplate.where(:platform => 'youtube_uscprofiles').order('cast(initial_id as integer)')
  end
end
