class CreateStreamFeeds < ActiveRecord::Migration
  def self.up
    create_table :stream_feeds do |t|
      t.integer :stream_id, :null => false
      t.string :title, :limit => 512, :null => false
      t.string :url, :limit => 512
      t.string :feed_type, :null => false, :default => 'RSS', :limit => 32
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :stream_feeds
  end
end
