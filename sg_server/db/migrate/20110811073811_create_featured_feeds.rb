class CreateFeaturedFeeds < ActiveRecord::Migration
  def self.up
    create_table :featured_feeds do |t|
      t.integer :feed_id, :null => false
      
      # paperclip fields
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :featured_feeds
  end
end
