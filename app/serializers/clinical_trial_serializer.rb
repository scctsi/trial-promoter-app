class ClinicalTrialSerializer < ActiveModel::Serializer
  attributes :id, :title, :pi_first_name, :pi_last_name, :url, :nct_id, :disease
end  