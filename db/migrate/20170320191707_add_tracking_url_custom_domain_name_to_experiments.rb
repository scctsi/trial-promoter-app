class AddTrackingUrlCustomDomainNameToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :tracking_url_custom_domain_name, :string
  end
end
