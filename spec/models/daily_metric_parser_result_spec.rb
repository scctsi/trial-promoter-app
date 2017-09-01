require 'rails_helper'

RSpec.describe DailyMetricParserResult  do
  it { is_expected.to serialize(:parsed_data).as(Hash) }
end
