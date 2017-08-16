class AddIpAddressToClick < ActiveRecord::Migration
  def change
    add_column :clicks, :ip_address, :text
  end
end
