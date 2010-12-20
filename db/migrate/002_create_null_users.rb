class CreateNullUsers < ActiveRecord::Migration
  def self.up
    # Null users have no database backend
  end

  def self.down
  end
end
