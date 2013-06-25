class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.string :title, :limit => 512, :null => false
      t.string :url, :limit => 512
      t.boolean :leaf, :default => false
      t.integer :parent_id
      t.string :feed_type, :null => false, :default => 'RSS', :limit => 32

      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end
