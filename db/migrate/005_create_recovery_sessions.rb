class CreateRecoverySessions < ActiveRecord::Migration
  def self.up
    create_table :recovery_sessions do |t|
      t.column :user_id, :int, :null => false
      t.column :remember_me, :string, :limit => 32, :null => false
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
    add_index :recovery_sessions, :remember_me
  end

  def self.down
    drop_table :recovery_sessions
  end
end
