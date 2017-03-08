class AddUniqueIndexForWebsites < ActiveRecord::Migration
  def change
    Website.all.each do |website|
      website.url = "#{website.id}"
      website.save
    end
    add_index :websites, :url, unique: true
  end
end
