class CreateFriends < ActiveRecord::Migration
  def self.up
    # Friends are really users
  end

  def self.down
    drop_table :friends
  end
end
