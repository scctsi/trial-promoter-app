# == Schema Information
#
# Table name: ad_campaigns
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdCampaign < ActiveRecord::Base
  has_many :messages
end
