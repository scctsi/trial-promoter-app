require "administrate/base_dashboard"

class ClinicalTrialDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    pi_first_name: Field::String,
    pi_last_name: Field::String,
    url: Field::String,
    nct_id: Field::String,
    disease: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :title,
    :pi_first_name,
    :pi_last_name,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :pi_first_name,
    :pi_last_name,
    :url,
    :nct_id,
    :disease,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :title,
    :pi_first_name,
    :pi_last_name,
    :url,
    :nct_id,
    :disease,
  ]

  # Overwrite this method to customize how clinical trials are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(clinical_trial)
  #   "ClinicalTrial ##{clinical_trial.id}"
  # end
end
