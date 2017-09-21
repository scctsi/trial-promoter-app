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
   