class MembersController < ApplicationController
  before_filter :authenticate, :except => [ :login, :validate, :logout, :forgotten_password, :update_password, :password_sent, :public_profile ]
  layout "main"

  def profile
    @user = User.find(session[:user].id)
    @photo = @user.photo
  end

  def public_profile
    @user = User.find_by_nickname(params[:nickname])
    @photo = @user.photo

    @page_title = "Members | Profile | " + @user.nickname.to_s
  end

  def update
    @user = User.find(session[:user].id)
    @user.update_attributes(params[:user])

    if params[:photo][:uploaded_data] != ""
      photo = Photo.create params[:photo]
      @user.photo = photo
    end

    @user.save
    flash[:notice] = 'Profile successfully updated.'
    redirect_to :action => 'profile'
  end

  def login
  end

  def validate
    if session[:user] = User.find( :first,
                                    :conditions => [ "LOWER(email) = LOWER(?) and password = MD5( ? )", @params[:login][:email], @params[:login][:password] ] )
      # Remember me
      rm = RecoverySession.new
      rm.user_id = session[:user].id

      while !rm.valid?
        # The following from http://www.bigbold.com/snippets/posts/show/491
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
        code = ''
        1.upto(32) { |i| code << chars[rand(chars.size-1)] }
        rm.remember_me = code
      end

      rm.save
      cookies[:remember_me] = { :domain => SITE_DOMAIN, :value => code, :expires => Time.now + ( 90 * (60*60*24) ) }

      redirect_to :controller => "members", :action => "profile"
    else
      flash[:notice] = 'There was a problem logging in. Please check your details and try again'
      redirect_to :action => "login"
    end
  end

  def forgotten_password
    user = User.find_by_email(params[:login][:email])

    # The following from http://www.bigbold.com/snippets/posts/show/491
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    password = ""
    1.upto(10) { |i| password << chars[rand(chars.size-1)] }
    user.password = MD5.new(password).to_s
    user.save

    # Revert to the plain text password for display in the email
    user.password = password

    # Lazy, lazy, lazy, This shouldn be in a user mailer, but hey ho...
    RegisterMailer.deliver_password(user)

    redirect_to :action => "password_sent"
  end

  def update_password
    @user = User.find(session[:user].id)
    @user.password = MD5.new(params[:user][:new_password]).to_s

    if @user.valid? && params[:user][:new_password] != "" && params[:user][:new_password].size > 5 && params[:user][:new_password].size < 20
      @user.save
      flash[:notice] = "Password updated!"
      redirect_to :action => "profile"
    else
      flash[:notice] = "Passwords must be between 5 and 20 characters"
      render :action => "profile"
    end
  end

  def password_sent
  end

  def logout
    session[:user] = nil
    cookies[:remember_me] = { :domain => SITE_DOMAIN, :value => nil, :expires => Time.now }
    redirect_to :controller => "home"
  end

  def upload
    document = Document.new(params[:document])
    document.save

    user = User.find(session[:user].id)
    user.documents << document
    user.save

    redirect_to :action => 'profile'
  end

  def tag
    document = Document.find(params[:id])
    document.tag params[:tags], :separator => ','
    document.save
    
    redirect_to :action => 'profile'
  end

  # From http://www.37signals.com/rails/wiki/Authentication.html
  protected
  def authenticate
    unless session[:user].id
      redirect_to :controller => "members", :action => "login"
      return false
    end
  end
end
