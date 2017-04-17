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
        messages.each { |message| failed_count += 1 if !(message.message_template.hashtags.nil? || message.message_template.hashtags.blank?) && !message.message_template.hashtags.any?{ |hashtag| !message.content.index(hashtag).nil? } }
      when :correct_destination_url
        messages.each do |message|
          # Wrong anchor link (if present)
          if !message.promoted_website_url.index('#').nil?
            anchor_link = message.promoted_website_url[message.promoted_website_url.index('#')..-1]
            destination_url_anchor_link = message.click_meter_tracking_link.destination_url[message.click_meter_tracking_link.destination_url.index('#')..-1]
            if anchor_link != destination_url_anchor_link
              failed_count += 1 
              next
            end
          end
          # Wrong website
          if !message.promoted_website_url.index('#').nil?
            promoted_website_url = message.promoted_website_url[0..(message.promoted_website_url.index('#') - 1)] 
          else
            promoted_website_url = message.promoted_website_url
          end
          failed_count += 1 if message.click_meter_tracking_link.destination_url.index(promoted_website_url).nil?
        end
      else
        failed_count = messages_count
    end

    (messages_count - failed_count) / messages_count
  end
end