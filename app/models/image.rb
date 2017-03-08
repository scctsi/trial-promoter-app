# == Schema Information
#
# Table name: images
#
#  id                :integer          not null, primary key
#  url               :string(2000)
#  original_filename :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Image < ActiveRecord::Base
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :experiments

  before_destroy :delete_image_from_s3

  validates :url, presence: true
  validates :original_filename, presence: true

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  has_many :messages

  def delete_image_from_s3
  end

  def s3_bucket
    url.split('/')[3]
  end

  def s3_key
    position = url.index(s3_bucket) + s3_bucket.length + 1
    url[position..(url.length-1)]
  end
end
