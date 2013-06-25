class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.string :title, :limit => 512
      t.integer :user_id, :null => false
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
