class FriendsController < ApplicationController
  def add
    user = User.find(session[:user].id)
    friend = Friend.find(params[:id])

    if user.nickname == friend.nickname
      flash[:notice] = "Can't add yourself as a friend!"
    elsif user.friends.include?(friend)
      flash[:notice] = 'Friend already added!'
    else
      user.friends << friend
      flash[:notice] = 'Friend successfully added!'
    end
    redirect_to :controller => 'members', :action => 'public_profile', :nickname => user.nickname
  end
end
