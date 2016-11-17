class Image < ActiveRecord::Base
  acts_as_ordered_taggable
  
  validates :url, presence: true
  validates :original_filename, presence: true
end
