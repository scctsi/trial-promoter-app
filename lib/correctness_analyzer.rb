class CorrectnessAnalyzer
  def analyze(experiment, test_name)
    messages = experiment.messages
    messages_count = messages.count.to_f
    failed_count = 0.0

    case test_name
      when :url_variable_replaced
        messages.each { |message| failed_count += 1 if !message.content.index('{url}').nil? }
      when :image_present
        messages.each { |message| failed_count += 1 if message.image.nil? }
      when :tracking_url_present
        messages.each { |message| failed_count += 1 if message.click_meter_tracking_link.nil? || message.content.index(message.click_meter_tracking_link.tracking_url).nil? }
      when :hashtag_included_if_applicable
        messages.each { |message| failed_count += 1 if !message.message_template.hashtags.nil? && !message.message_template.hashtags.any?{ |hashtag| !message.content.index(hashtag).nil? } }
    end

    (messages_count - failed_count) / messages_count
  end
end