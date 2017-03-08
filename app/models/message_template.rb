# == Schema Information
#
# Table name: message_templates
#
#  id                   :integer          not null, primary key
#  content              :text
#  platform             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hashtags             :text
#  experiment_variables :text
#

class MessageTemplate < ActiveRecord::Base
  MAXIMUM_TWEET_LENGTH = 140
  
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments

  extend Enumerize

  validates :content, presence: true
  validates :platforms, presence: true
  enumerize :platforms, in: [:twitter, :facebook, :instagram], multiple: true

  serialize :platforms, Array
  serialize :hashtags, Array
  serialize :image_pool, Array
  serialize :experiment_variables, Hash
  serialize :original_image_filenames, Array
  
  has_many :messages

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  STANDARD_VARIABLES = [/{\s*pi_first_name\s*}/i, /{\s*pi_last_name\s*}/i, /{\s*disease\s*}/i, /{\s*title\s*}/i, /{\s*name\s*}/i, /{\s*url\s*}/i]
  
  def platform
    return self[:platform].to_sym if !self[:platform].nil?
    nil
  end
    
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

    self[:content] = cleaned_content
  end
  
  def hashtags=(hashtags)
    if hashtags.nil?
      self[:hashtags] = []
      return
    end
    
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
    
    self[:hashtags] = cleaned_hashtags
  end
  
  def warnings
    warnings = []
    return [] if content.nil?
    
    warnings << 'Too long for use in Twitter' if content.length > 140
    warnings << 'Too long for use in Twitter (URL takes up 23 characters)' if content.include?('{url}') and content.length > 117 + '{url}'.length
    
    # Hashtag inclusion checks
    if !hashtags.nil? && !(hashtags.length == 0)
      if content.length + hashtags.map(&:length).min > 140
        warnings << 'Too long for use in Twitter (None of the hashtags will ever be included)'
      elsif content.length + hashtags.map(&:length).max > 140
        warnings << 'Too long for use in Twitter (At least one of the hashtags will never be included)'
      end
    end
    
    warnings
  end
end
