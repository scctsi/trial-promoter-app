class OrganicMessagesController < ApplicationController
  def index
    @twitter_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'twitter', 'organic').order('scheduled_at, message_type, image_required')
    @pending_twitter_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'twitter', 'organic', (Time.now + 7.days).utc.to_date)
    @twitter_uscprofiles_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'twitter_uscprofiles', 'organic').order('scheduled_at, message_type, image_required')
    @pending_twitter_uscprofiles_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'twitter_uscprofiles', 'organic', (Time.now + 7.days).utc.to_date)
    @facebook_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'organic').order('scheduled_at, message_type, image_required')
    @pending_facebook_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'facebook', 'organic', (Time.now + 7.days).utc.to_date)
    @facebook_uscprofiles_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook_uscprofiles', 'organic').order('scheduled_at, message_type, image_required')
    @pending_facebook_uscprofiles_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ?", 'facebook_uscprofiles', 'organic', (Time.now + 7.days).utc.to_date)
  end

  def set_image_urls
    message = Message.find(params[:message_id])
    message.image_url = params[:image_url]
    message.thumbnail_url = params[:thumbnail_url]
    message.save

    render :json => {
    }
  end

  def publish
    if Rails.env.development?
      WebMock.allow_net_connect!
    end

    social_media_poster = SocialMediaPoster.new
    messages_published_count = social_media_poster.publish_pending(params[:platform], params[:medium])

    if Rails.env.development?
      WebMock.disable_net_connect!
    end

    flash[:message] = "#{messages_published_count} #{params[:medium].titlecase} #{params[:platform].titlecase} message(s) were sent to Buffer. Please check Buffer!"
    redirect_to(:controller => 'organic_messages', :action => 'index')
  end
end
