FactoryGirl.define do
  factory :clinical_trial do
    title "Cancer Study"
    pi_first_name "John"
    pi_last_name "Doe"
    url "http://www.clinicaltrial.com/"
    disease "Cancer"
  end
  
  factory :invalid_clinical_trial, parent: :clinical_trial do
    title nil
    pi_first_name nil
    pi_last_name nil
    url nil
    disease nil
  end
end