class Modification < ActiveRecord::Base
  validates :experiment, presence: true

  belongs_to :experiment
end
