require 'rails_helper'
require 'yaml'

RSpec.describe BijectiveFunction do
  it 'encodes an integer' do
    expect(BijectiveFunction.encode(1250000000)).to eq('bwK2gu')
  end
  
  it 'decodes a string' do
    expect(BijectiveFunction.decode('bwK2gu')).to eq(1250000001)
  end
end