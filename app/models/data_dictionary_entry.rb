class DataDictionaryEntry < ActiveRecord::Base
  extend Enumerize

  validates :trial_promoter_label, presence: true
  enumerize :source, in: [:buffer, :twitter, :facebook, :instagram, :google_analytics]
end
