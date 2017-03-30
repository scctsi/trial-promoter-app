require 'rails_helper'

RSpec.describe Throttler do
  it 'can throttle an action' do
    allow(Kernel).to receive(:sleep)
    
    Throttler.throttle(10)
    
    expect(Kernel).to have_received(:sleep).with(0.1)
  end
end