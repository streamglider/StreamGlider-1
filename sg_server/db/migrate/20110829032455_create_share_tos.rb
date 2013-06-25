class CreateShareTos < ActiveRecord::Migration
  def self.up
    create_table :share_tos do |t|
      t.integer :user_id, :null => false
      t.integer :stream_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :share_tos
  end
end
