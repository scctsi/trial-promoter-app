require 'rails_helper'
require 'yaml'

RSpec.describe BijectiveFunction do
  it 'only uses a alphabet consisting of lowercase letters and numbers' do
    # Click Meter does not distinguish between names that differe in case.
    # Example: 9nl.es/name and 9nl.es/NAME are the same!
    # So we restrict the alphabet for the Bijective function to lowercase only
    expect(BijectiveFunction::ALPHABET).to eq("bcdfghjklmnpqrstvwxyz0123456789".split(//))
  end
  
  it 'encodes an integer' do
    expect(BijectiveFunction.encode(1250000000)).to eq('uyh4gi')
  end
  
  it 'decodes a string' do
    expect(BijectiveFunction.decode('uyh4gi')).to eq(1250000000)
  end
end