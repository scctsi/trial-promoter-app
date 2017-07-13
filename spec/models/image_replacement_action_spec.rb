require 'rails_helper'

RSpec.describe ImageReplacementAction do
  it { is_expected.to serialize(:replacements).as(Hash) }
end
