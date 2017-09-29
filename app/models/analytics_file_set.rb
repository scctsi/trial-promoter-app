# == Schema Information
#
# Table name: analytics_file_sets
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AnalyticsFileSet < ActiveRecord::Base
  has_many :analytics_files
end
