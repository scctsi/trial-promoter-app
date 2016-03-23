class MessageTemplate < ActiveRecord::Base
  validates :content, presence: true
  validates :platform, presence: true

  STANDARD_VARIABLES = [/{\s*pi_first_name\s*}/i, /{\s*pi_last_name\s*}/i, /{\s*disease\s*}/i, /{\s*url\s*}/i]
    
  def content=(content)
    # When the content is set, make sure that all variables are downcased and stripped of unnecessary whitespace between the {} brackets
    return if content.blank?

    # Does the content of the message template contain any of the standard variables?
    STANDARD_VARIABLES.each do |variable|
      matches = content.scan(variable)
      
      if matches.size > 0
        content.gsub!(matches[0], matches[0].downcase.gsub(/\s/, ''))
      end
    end

    write_attribute(:content, content)
  end
  
  def generate_message(clinical_trial)
    url_shortener = UrlShortener.new
    message = Message.new(content: self.content)
    
    STANDARD_VARIABLES.each do |variable|
      matches = message.content.scan(variable)
      
      if matches.size > 0
        # The attribute name that we need to substitute is the variable without the sorrounding curly braces
        # Example when the variable is {pi_first_name}, we need to get the value of pi_first_name from the clinical trial
        attribute_name = matches[0].gsub('{', '').gsub('}', '')
        if matches[0] == '{url}' # Shorten the url
          message.content.gsub!(matches[0], url_shortener.shorten(clinical_trial.url))
        else
          message.content.gsub!(matches[0], clinical_trial.send(attribute_name))
        end
          
      end
    end
    
    message
  end
end
