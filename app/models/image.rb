# == Schema Information
#
# Table name: images
#
#  id                              :integer          not null, primary key
#  url                             :string(2000)
#  original_filename               :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  width                           :integer
#  height                          :integer
#  meets_instagram_ad_requirements :boolean
#


class Image < ActiveRecord::Base
  acts_as_ordered_taggable_on :experiments

  before_destroy :delete_image_from_s3 

  serialize :codes, Hash
  validates :url, presence: true
  validates :original_filename, presence: true

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  has_many :messages

  def filename
    url[(url.rindex('/') + 1)..-1]
  end
  
  def self.set_duplicate(duplicated_image_filename, duplicate_image_filename)
    duplicated_image = Image.where('url LIKE ?', "%#{duplicated_image_filename}%")[0]
    duplicate_image = Image.where('url LIKE ?', "%#{duplicate_image_filename}%")[0]
    
    duplicated_image.duplicates << duplicate_image
    duplicated_image.save
  end
  
  def delete_image_from_s3
    s3 = S3Client.new
    s3.delete(s3.bucket(self.url), s3.key(self.url))
  end
end
