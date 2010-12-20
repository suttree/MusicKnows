class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :user_id, :int, :null => false
      t.column :memory_id, :int, :null => false
      t.column :parent_id, :int
      t.column :title, :string, :null => false
      t.column :body, :text, :null => false
      t.column :updated_on, :datetime
      t.column :created_on, :datetime
    end

    add_index :comments, :user_id
    add_index :comments, :memory_id
  end

  def self.down
    drop_table :comments
  end
end
