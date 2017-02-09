FactoryGirl.define do
  factory :data_dictionary_entry do
    data_dictionary
    variable_name 'sessions'
    source :google_analytics
  end
end