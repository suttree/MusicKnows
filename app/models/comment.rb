class Comment < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :memory
  acts_as_tree  :order => "id"

  validates_presence_of   :user_id, :memory_id, :title, :body
end
