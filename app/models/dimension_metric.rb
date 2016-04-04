class DimensionMetric < ActiveRecord::Base
  serialize :dimensions
  serialize :metrics
end