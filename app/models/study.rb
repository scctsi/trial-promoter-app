class Study < ActiveRecord::Base
  has_many :experiments
  has_many :institutions
end
