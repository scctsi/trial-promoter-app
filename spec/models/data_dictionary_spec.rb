# == Schema Information
#
# Table name: data_dictionaries
#
#  id            :integer          not null, primary key
#  experiment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#



require 'rails_helper'

RSpec.describe DataDictionary do
  before do
    @experiment = create(:experiment)
  end
  
  it { is_expected.to have_many :data_dictionary_entries }
  it { is_expected.to belong_to :experiment }
  it { is_expected.to validate_presence_of :experiment }
  it { is_expected.to accept_nested_attributes_for(:data_dictionary_entries) }

  it 'has a pre-defined hash of data elements (key is the source, value is an array of trial promoter labels)' do
    data_elements = DataDictionary::DATA_ELEMENTS
    
    expect(data_elements[:facebook]).to eq(['impressions', 'shares', 'comments', 'likes'].sort)
    expect(data_elements[:google_analytics]).to eq(['sessions', 'users', 'exits', 'session_duration', 'time_on_page', 'pageviews'].sort)
    expect(data_elements[:instagram]).to eq(['impressions', 'reposts', 'comments', 'likes'].sort)
    expect(data_elements[:trial_promoter]).to eq(['ordinal_day', 'date_sent', 'day_of_week_sent', 'time_sent', 'platform', 'medium', 'image_used', 'tags', 'link_clicks', 'click_time'].sort)
    expect(data_elements[:twitter]).to eq(['impressions', 'retweets', 'replies', 'likes'].sort)
  end
  
  it 'has a pre-defined hash of allowed values for certain data elements' do
    allowed_values = DataDictionary::ALLOWED_VALUES

    expect(allowed_values[:trial_promoter_day_of_week_sent]).to eq(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
    expect(allowed_values[:trial_promoter_platform]).to eq(['Twitter', 'Facebook', 'Instagram'])
    expect(allowed_values[:trial_promoter_medium]).to eq(['Ad', 'Organic'])
    expect(allowed_values[:trial_promoter_image_used]).to eq(['Yes', 'No'])
  end
  
  it 'creates a new dictionary for an experiment with an entry for every pre-defined data element' do
    DataDictionary.create_data_dictionary(@experiment)
    @experiment.reload
    
    expect(@experiment.data_dictionary).not_to be nil
    number_of_pre_defined_data_elements = DataDictionary::DATA_ELEMENTS.values.inject(0) { |total, elements| total + elements.length }
    # Is there one data dictionary entry for each pre-defined data element?
    expect(@experiment.data_dictionary.data_dictionary_entries.length).to eq(number_of_pre_defined_data_elements)
    # Are all the variable names and sources correctly set?
    variable_names = @experiment.data_dictionary.data_dictionary_entries.map(&:variable_name)
    DataDictionary::DATA_ELEMENTS.keys.each do |source|
      DataDictionary::DATA_ELEMENTS[source].each do |variable_name|
        expect(variable_names).to include("#{source}_#{variable_name}")
        entry_with_matching_variable_name = @experiment.data_dictionary.data_dictionary_entries.select{ |data_dictionary_entry| data_dictionary_entry.variable_name == "#{source}_#{variable_name}" }[0]
        expect(entry_with_matching_variable_name.source).to eq(source)
      end
    end
    # Are all the pre-defined allowed values correctly set?
    DataDictionary::ALLOWED_VALUES.keys.map(&:to_s).each do |variable_name|
      entry_with_correct_variable_name = @experiment.data_dictionary.data_dictionary_entries.select{ |data_dictionary_entry| data_dictionary_entry.variable_name == variable_name }[0]
      expect(entry_with_correct_variable_name.allowed_values).to eq(DataDictionary::ALLOWED_VALUES[variable_name.to_sym])
    end
  end
  
  it 'does not delete an existing data dictionary for an experiment' do
    DataDictionary.create_data_dictionary(@experiment)
    old_data_dictionary = @experiment.data_dictionary
    DataDictionary.create_data_dictionary(@experiment)
    new_data_dictionary = @experiment.data_dictionary
    @experiment.reload
    
    expect(new_data_dictionary).to eq(old_data_dictionary)
  end
end
