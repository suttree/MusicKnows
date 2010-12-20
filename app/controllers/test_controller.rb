class TestController < ApplicationController
  layout "main"

  def friends
    session[:friends] = Array.new
    @user = User.find(session[:user].id)
  end

  def add_friend
    friend_id = params[:id].split("_")[1]
    friend = User.find(friend_id)

    if session[:friends].include?(friend_id)
      flash[:partial_notice] = friend.nickname + " already added!"
    else
      flash[:partial_notice] = friend.nickname + " added!"
      session[:friends] << friend_id
    end

    render :partial => 'friendslist'
  end

  def remove_friend
    # Remove the friend from the list and re-render it
    current_friends = session[:friends]
    session[:friends] = Array.new

    for friend_id in current_friends
      if friend_id != params[:id]
        session[:friends] << friend_id
      end
    end

    friend = User.find(params[:id])
    flash[:partial_notice] = friend.nickname + " removed!"

    render :partial => 'friendslist'
  end
end
