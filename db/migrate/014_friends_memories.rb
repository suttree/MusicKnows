class FriendsMemories < ActiveRecord::Migration
  def self.up
    create_table :friends_memories, :id => false  do |t|
      t.column :friend_id, :int, :null => false
      t.column :memory_id, :int, :null => false
    end

    add_index :friends_memories, :friend_id
    add_index :friends_memories, :memory_id
  end

  def self.down
    drop table :friends_memories
  end
end
