class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.column "memory_id", :integer
      t.column "user_id", :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      t.column "width", :integer  
      t.column "height", :integer
    end

    add_index :photos, :memory_id
    add_index :photos, :user_id
  end

  def self.down
    drop_table :photos
  end
end
