# == Schema Information
#
# Table name: message_templates
#
#  id         :integer          not null, primary key
#  content    :text
#  platform   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hashtags   :text
#

class MessageTemplate < ActiveRecord::Base
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments

  extend Enumerize

  validates :content, presence: true
  validates :platform, presence: true
  enumerize :platform, in: [:twitter, :facebook], predicates: true

  serialize :hashtags
  
  has_many :messages

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  STANDARD_VARIABLES = [/{\s*pi_first_name\s*}/i, /{\s*pi_last_name\s*}/i, /{\s*disease\s*}/i, /{\s*title\s*}/i, /{\s*name\s*}/i, /{\s*url\s*}/i]
    
  def content=(content)
    cleaned_content = content
    
    # When the content is set, make sure that all variables are downcased and stripped of unnecessary whitespace between the {} brackets
    return if cleaned_content.blank?

    # Does the content of the message template contain any of the standard variables?
    STANDARD_VARIABLES.each do |variable|
      matches = cleaned_content.scan(variable)
           
      if matches.size > 0
        cleaned_content.gsub!(matches[0], matches[0].downcase.gsub(/\s/, ''))
      end
    end

    write_attribute(:content, cleaned_content)
  end
  
  def hashtags=(hashtags)
    cleaned_hashtags = hashtags
    
    # Convert comma separated string to an array of strings
    if cleaned_hashtags.is_a? String
      cleaned_hashtags = cleaned_hashtags.split(",").map{ |hashtag| hashtag.strip }
    end
    
    # Add a leading hash (#) if needed to each hashtag
    cleaned_hashtags = cleaned_hashtags.map do |hashtag|
      if hashtag.starts_with?('#')
        hashtag
      else
        hashtag = '#' + hashtag
      end
    end
    
    write_attribute(:hashtags, cleaned_hashtags)
  end
  
  def generate_message(clinical_trial)
    url_shortener = UrlShortener.new
    message = Message.new(text: self.content)
    
    STANDARD_VARIABLES.each do |variable|
      matches = message.text.scan(variable)
      
      if matches.size > 0
        # The attribute name that we need to substitute is the variable without the sorrounding curly braces
        # Example when the variable is {pi_first_name}, we need to get the value of pi_first_name from the clinical trial
        attribute_name = matches[0].gsub('{', '').gsub('}', '')
        if matches[0] == '{url}' # Shorten the url
          message.text.gsub!(matches[0], url_shortener.shorten(clinical_trial.url))
        else
          message.text.gsub!(matches[0], clinical_trial.send(attribute_name))
        end
          
      end
    end
    
    message
  end
end
