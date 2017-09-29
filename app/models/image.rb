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
  
  def delete_image_from_s3
    s3 = S3Client.new
    s3.delete(s3.bucket(self.url), s3.key(self.url))
  end
   
  def map_codes(code_object) 
    if code_object == []
      self.codes = {}
    else
      hash = {}
      code_object.each do |code_pair|
        key_value = code_pair.split(':') 
        hash[key_value[0]] = key_value[1] 
      end
      self.codes = hash
    end
    save
  end 
end
   