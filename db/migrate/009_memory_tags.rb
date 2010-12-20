class MemoryTags < ActiveRecord::Migration
  def self.up
    create_table :memories_tags, :id => false do |t|
      t.column :tag_id, :int, :null => false
      t.column :memory_id, :int, :null => false
    end

    add_index :memories_tags, :tag_id
    add_index :memories_tags, :memory_id
  end

  def self.down
    drop_table :memories_tags
  end
end
