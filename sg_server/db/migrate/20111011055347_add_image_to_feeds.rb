class AddImageToFeeds < ActiveRecord::Migration
  def self.up
    change_table(:feeds) do |t|
      # paperclip fields
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at   
    end  
  end

  def self.down
    change_table(:featured_feeds) do |t|
      t.remove :image_file_name
      t.remove :image_content_type
      t.remove :image_file_size
      t.remove :image_updated_at      
    end    
  end
  
end
