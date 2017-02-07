FactoryGirl.define do
  factory :data_dictionary_entry do
    data_dictionary
    trial_promoter_label 'label'
    source :google_analytics
  end
end