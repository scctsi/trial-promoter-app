class Campaign < ActiveRecord::Base
  scope :current, -> { where('(start_date is null and end_date is null) or (start_date is not null and start_date <= ?) or (end_date is not null and end_date >= ?)', DateTime.now, DateTime.now) }
  
  validates :name, presence: true
  
  has_and_belongs_to_many :clinical_trials
end
