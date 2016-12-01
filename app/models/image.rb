class Image < ActiveRecord::Base
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments
  
  validates :url, presence: true
  validates :original_filename, presence: true
end
