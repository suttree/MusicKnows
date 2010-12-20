class User < ActiveRecord::Base
  has_one :photo
  has_many :comments
  has_many :memories
  has_and_belongs_to_many :friends

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/  
  validates_length_of :password, :within => 5..32
  validates_presence_of :email, :nickname, :password
  validates_uniqueness_of :nickname, :email

  def admin?
    return self.admin
  end
end
