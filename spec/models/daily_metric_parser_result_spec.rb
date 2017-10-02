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

require 'rails_helper'

RSpec.describe DailyMetricParserResult  do
  it { is_expected.to serialize(:parsed_data).as(Hash) }
end
