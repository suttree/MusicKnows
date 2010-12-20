class CreateMemories < ActiveRecord::Migration
  def self.up
    create_table :memories do |t|
      t.column :title, :string, :null => false
      t.column :body, :text, :null => false
      t.column :user_id, :int, :null => false
      t.column :url_name, :string, :null => false
      t.column :year, :int, :limit => 4, :null => false
      t.column :month, :int, :limit => 2
      t.column :day, :int, :limit => 2
      t.column :updated_on, :datetime
      t.column :created_on, :datetime
    end

    add_index :memories, :year
    add_index :memories, :month
    add_index :memories, :day
    add_index :memories, :url_name
  end

  def self.down
    drop_table :memories
  end
end
