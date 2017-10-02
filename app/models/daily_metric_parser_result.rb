# == Schema Information
#
# Table name: daily_metric_parser_results
#
#  id          :integer          not null, primary key
#  file_date   :date
#  file_path   :text
#  parsed_data :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DailyMetricParserResult < ActiveRecord::Base
  serialize :parsed_data, Hash
end
