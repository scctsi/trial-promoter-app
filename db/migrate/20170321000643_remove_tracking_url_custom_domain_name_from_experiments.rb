class RemoveTrackingUrlCustomDomainNameFromExperiments < ActiveRecord::Migration
  def change
    remove_column :experiments, :tracking_url_custom_domain_name, :string
  end
end
