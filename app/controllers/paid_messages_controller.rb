class PaidMessagesController < ApplicationController
  def index
    @facebook_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'paid').order('scheduled_at, message_type, image_required')
    @pending_facebook_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'facebook', 'paid', (Time.now + 7.days).utc.to_date)
    @facebook_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
    @pending_facebook_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'facebook_uscprofiles', 'paid', (Time.now + 7.days).utc.to_date)
    @google_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google', 'paid').order('scheduled_at, message_type, image_required')
    @google_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
    @youtube_search_results_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_search_results', 'paid').order('scheduled_at, message_type, image_required')
    @youtube_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
  end
end
