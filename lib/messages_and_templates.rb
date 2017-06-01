require 'csv'
require 'ahoy_matey'

class MessagesAndTemplates

  def get_conversions
    (Ahoy::Event.where(name: "Converted").uniq.pluck(:visit_id)).select{ |v| Visit.find(v) if v != nil}
  end

  def get_visits(visit_ids)
    # visits = []
    # visitors.each do |visit|
    #   visits << Visit.find(visit)
    # end
    return Visit.find(visit_ids)
    # after april 19?
   #visits = visits.select{|v| v.started_at > "2017-04-19"}
  end

# for each visit, find the utm_content, which is the Message id
#  from that message, get the corresponding message_template


  def get_utm_content(visits)
    content = []
    visits.each do |v|
      content << v.utm_content
    end
    return content
  end

  def get_messages(utm_contents)
    message_templates=[]
    message_objects=[]
    messages = Message.all
    messages = messages.to_a
    messages.select{|msg| utm_contents.include?(msg.to_param ) }

    return messages
  end

  def export(messages, goal_counts)
    CSV.open("#{Rails.root}/public/messages_and_templates.csv", "wb") do |csv|
      messages.each do |message|
        goal_count_for_message = goal_counts.select{|goal_count, message_params| message_params.include?(message.to_param)}.keys[0]
        csv << message.attributes.values + message.message_template.attributes.values + [message.to_param] + [goal_count_for_message]
      end
    end
  end

  def get_goal_counts(messages)
    messages.map(&:to_param).uniq.group_by { |message_param| messages.select {|message| message.to_param == message_param}.count }
  end
end

messages_and_templates = MessagesAndTemplates.new

visit_ids = messages_and_templates.get_conversions
visits = messages_and_templates.get_visits(visit_ids)
utm_contents = messages_and_templates.get_utm_content(visits)
messages = messages_and_templates.get_messages(utm_contents)
goal_counts = messages_and_templates.get_goal_counts(messages)
messages_and_templates.export(messages, goal_counts)


#  export both the message and the message_template into a csv file

 # should be about 350 ish