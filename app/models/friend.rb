class Friend < ActiveRecord::Base
  set_table_name "users" 
  has_and_belongs_to_many :memories
  has_and_belongs_to_many :users
end
