class AddPositionToFeeds < ActiveRecord::Migration
  def self.up
    change_table(:feeds) do |t|
      t.integer :position, :default => 0
      
    end  
  end

  def self.down
    change_table(:feeds) do |t|
      t.remove :position
    end    
  end
  
end
