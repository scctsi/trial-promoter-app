# == Schema Information
#
# Table name: image_replacements
#
#  id                   :integer          not null, primary key
#  message_id           :integer
#  previous_image_id    :integer
#  replacement_image_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class ImageReplacement < ActiveRecord::Base
  validates :message, presence: true
  validates :previous_image, presence: true
  validates :replacement_image, presence: true

  belongs_to :message
  belongs_to :previous_image, class_name: 'Image'
  belongs_to :replacement_image, class_name: 'Image'
end
