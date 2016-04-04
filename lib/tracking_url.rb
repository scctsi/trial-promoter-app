class TrackingUrl
  attr_accessor :message

  def initialize(message)
    self.message = message
  end

  def tracking_fragment(source, medium, campaign)
    "utm_source=#{source}&utm_medium=#{medium}&utm_campaign=#{campaign}"
  end

  def value(medium, campaign)
    if (!message.clinical_trial.blank?)
      return "#{message.clinical_trial.url}/?#{tracking_fragment(message.message_template.platform, medium, campaign)}"
    else
      return "http://profiles.sc-ctsi.org/search/?#{tracking_fragment(message.message_template.platform, medium, campaign)}"
    end
  end
end