class FriendsUsers < ActiveRecord::Migration
  def self.up
    create_table :friends_users, :id => false  do |t|
      t.column :friend_id, :int, :null => false
      t.column :user_id, :int, :null => false
    end

    add_index :friends_users, :friend_id
    add_index :friends_users, :user_id
  end

  def self.down
    drop table :friends_users
  end
end
