class MessageTemplate < ActiveRecord::Base
  validates :content, presence: true
  validates :platform, presence: true

  STANDARD_VARIABLES = [/{\s*pi_first_name\s*}/i, /{\s*pi_last_name\s*}/i, /{\s*disease\s*}/i]
    
  def content=(content)
    return if content.blank?

    # Does the content of the message template contain any of the standard variables?
    STANDARD_VARIABLES.each do |variable|
      matches = content.scan(variable)
      
      if matches.size > 0
        puts "Match: #{matches[0]}"
        content.gsub!(matches[0], matches[0].downcase.gsub(/\s/, ''))
      end
    end

    write_attribute(:content, content)
  end
end
