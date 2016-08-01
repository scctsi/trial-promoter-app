class Campaign < ActiveRecord::Base
  validates :name, presence: true    
end
