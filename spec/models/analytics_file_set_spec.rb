require 'rails_helper'

RSpec.describe AnalyticsFileSet do
  it { is_expected.to have_many :analytics_files }
end
