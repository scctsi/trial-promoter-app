# == Schema Information
#
# Table name: data_dictionary_entries
#
#  id                 :integer          not null, primary key
#  include_in_report  :boolean
#  variable_name      :string
#  report_label       :string
#  integrity_check    :string
#  source             :string
#  note               :text
#  data_dictionary_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  allowed_values     :text
#  value_mapping      :text
#


class DataDictionaryEntry < ActiveRecord::Base
  extend Enumerize

  validates :variable_name, presence: true
  validates :source, presence: true
  enumerize :source, in: [:buffer, :experiment, :facebook, :instagram, :google_analytics, :trial_promoter, :twitter]

  belongs_to :data_dictionary
  validates :data_dictionary, presence: true

  serialize :allowed_values
  serialize :value_mapping
end
