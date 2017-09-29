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
  include Codeable
  acts_as_ordered_taggable_on :experiments
  acts_as_taggable_on :codes

  before_destroy :delete_image_from_s3 

  validates :url, presence: true
  validates :original_filename, presence: true

  scope :belonging_to, ->(experiment) { tagged_with(experiment.to_param, on: :experiments) }

  has_many :messages
  has_many :duplicates, class_name: 'Image', foreign_key: 'duplicated_image_id'
  belongs_to :duplicated_image, class_name: 'Image'

  def delete_image_from_s3
    s3 = S3Client.new
    s3.delete(s3.bucket(self.url), s3.key(self.url)) 
  end
end
<<<<<<< HEAD

=======
   
>>>>>>> perspective
