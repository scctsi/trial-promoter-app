class PostTemplate < ActiveRecord::Base
  belongs_to :social_media_specification
  validates :social_media_specification, presence: true
  belongs_to :experiment
  validates :experiment, presence: true
  store :content, coder: JSON
  serialize :image_pool, Array
end

