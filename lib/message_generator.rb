class MessageGenerator
  def generate(message_template, clinical_trial)
    message = Message.new(content: message_template.content)
    
    MessageTemplate::STANDARD_VARIABLES.each do |variable|
      matches = message.content.scan(variable)
      
      if matches.size > 0
        # The attribute name that we need to substitute is the variable without the surrounding curly braces
        # Example when the variable is {pi_first_name}, we need to get the value of pi_first_name from the clinical trial
        attribute_name = matches[0].gsub('{', '').gsub('}', '')
        message.content.gsub!(matches[0], clinical_trial.send(attribute_name))
      end
    end
    
    message
  end
end