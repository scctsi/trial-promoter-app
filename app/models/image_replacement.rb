class ImageReplacement < ActiveRecord::Base
  validates :message, presence: true
  validates :previous_image, presence: true
  validates :replacement_image, presence: true

  belongs_to :message
  belongs_to :previous_image, class_name: 'Image'
  belongs_to :replacement_image, class_name: 'Image'
end
