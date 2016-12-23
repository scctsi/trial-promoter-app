class SocialNetworkPublishDateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :social_network_publish_date, :datetime
  end
end
