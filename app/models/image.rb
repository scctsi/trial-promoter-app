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
#  duplicated_image_id             :integer
#

class Image < ActiveRecord::Base
  acts_as_ordered_taggable_on :experiments
  acts_as_taggable_on :codes

  before_destroy :delete_image_from_s3

  validates :url, presence: true
  validates :original_filename, presence: true

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  has_many :messages
  has_many :duplicates, class_name: 'Image', foreign_key: 'duplicated_image_id'
  belongs_to :duplicated_image, class_name: 'Image'

  def filename
    url[(url.rindex('/') + 1)..-1]
  end
  
  def self.set_duplicate(duplicated_image_filename, duplicate_image_filename)
    duplicated_image = Image.where('url LIKE ?', "%#{duplicated_image_filename}%")[0]
    duplicate_image = Image.where('url LIKE ?', "%#{duplicate_image_filename}%")[0]
    
    return if duplicate_image.nil? || duplicated_image.nil?
    
    duplicated_image.duplicates << duplicate_image
    duplicate_image.save
    duplicated_image.save
  end
  
  def experiment
    return Experiment.find_by_param(experiment_list[0])
  end
  
  def delete_image_from_s3
    # TODO: Fix callback; manual deletion in S3 for now
    # s3 = S3Client.new(experiment)
    # s3.delete(s3.bucket(url), s3.key(url)) 
  end
end