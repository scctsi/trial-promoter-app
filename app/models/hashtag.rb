# == Schema Information
#
# Table name: hashtags
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Hashtag < ActiveRecord::Base
  validates :phrase, presence: true
  validates :phrase, uniqueness: true
end
