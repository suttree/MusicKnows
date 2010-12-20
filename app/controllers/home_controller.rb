class HomeController < ApplicationController
  layout "main"

  def index
    # Site homepage
    @latest_comments = Comment.find( :all, :order => 'updated_on DESC', :limit => 5 )
    @latest_memories = Memory.find( :all, :order => 'updated_on DESC', :limit => 5 )
    @latest_users = User.find( :all, :order => 'updated_on DESC', :limit => 5 )
  end
end
