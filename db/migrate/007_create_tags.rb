class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :null => false
      t.column :url_name, :string, :null => false
      t.column :category, :string
    end

    add_index :tags, :url_name
  end

  def self.down
    drop_table :tags
  end
end
