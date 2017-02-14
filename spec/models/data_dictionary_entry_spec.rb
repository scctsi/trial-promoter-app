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

require 'rails_helper'

RSpec.describe DataDictionaryEntry do
  it { is_expected.to validate_presence_of :variable_name }
  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to enumerize(:source).in(:buffer, :experiment, :facebook, :instagram, :google_analytics, :trial_promoter, :twitter) }
  it { is_expected.to belong_to(:data_dictionary) }
  it { is_expected.to validate_presence_of(:data_dictionary) }
  
  it 'stores allowed values as an array' do
    data_dictionary_entry = build(:data_dictionary_entry)
    data_dictionary_entry.allowed_values = ['Monday', 'Tuesday']
    
    data_dictionary_entry.save
    data_dictionary_entry.reload
    
    expect(data_dictionary_entry.allowed_values).to eq(['Monday', 'Tuesday'])
  end
  
  it 'stores value mapping as a hash' do
    data_dictionary_entry = build(:data_dictionary_entry)
    data_dictionary_entry.value_mapping = { 'Monday' => '0', 'Tuesday' => '1' }
    
    data_dictionary_entry.save
    data_dictionary_entry.reload
    
    expect(data_dictionary_entry.value_mapping).to eq({ 'Monday' => '0', 'Tuesday' => '1' })
  end
end
