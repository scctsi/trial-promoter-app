class Institution < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :studies
  has_many :experiments, through: :studies
end
