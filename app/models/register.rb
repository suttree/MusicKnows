class Register < ActiveRecord::Base
  require 'md5'
  set_table_name "users" 

  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/  
  validates_length_of :password, :within => 5..20
  validates_presence_of :email, :nickname, :password
  validates_uniqueness_of :nickname, :email

  def before_create
    self.password = MD5.new(self.password).to_s
  end

  def after_create
    @password = nil
  end
end
