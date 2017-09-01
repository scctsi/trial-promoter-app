class DailyMetricParserResult < ActiveRecord::Base
  serialize :parsed_data, Hash
end
