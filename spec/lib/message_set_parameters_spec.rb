require 'rails_helper'

RSpec.describe MessageSetParameters do
  before do
  end
  
  it 'has a field with the tag of the website to promote' do
    
  end
  
  
  # -----------------
  # Example 1 (TCORS)
  # -----------------
  # Select websites/clinical trials with certain tags to promote (Promote Set)
  # - Select websites with tcors tag
  # - If 1, no randomize or cycle selection allowed
  # Select message template with certain tags
  # - Select message template with tcors tag
  # - Randomly select from set
  # Randomize/Cycle through ads/organic
  # - Cycle
  # Randomize/Cycle through Social Networks
  # - Cycle
  # Randomize/Cycle image / no image
  # - Randomize
  # Do this for a certain number of days
  # - 182 days
  # Do this per SM for a certain number of messages
  # - 5 
end