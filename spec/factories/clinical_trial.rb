FactoryGirl.define do
  factory :clinical_trial do
    title "Cancer Study"
    pi_first_name "John"
    pi_last_name "Doe"
    url "http://www.clinicaltrial.com/"
    disease "Cancer"
  end
end