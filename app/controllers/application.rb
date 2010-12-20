# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  before_filter :remember_me

  def remember_me
    if session[:user] != nil
      if session[:user].id == nil
        session[:logged_in] = false
      else
        session[:logged_in] = true
      end
      return
    elsif cookies[:remember_me]
      if rm = RecoverySession.find(   :first, :conditions => [ "remember_me = ?", cookies[:remember_me] ] )
        if session[:user] = User.find_by_id( rm.user_id )
          session[:logged_in] = true
          return
        else
          session[:user] = NullUser.new
          session[:logged_in] = false

          old_sessions = RecoverySession.find( :all, :conditions => [ "remember_me = ?", cookies[:remember_me] ] )
          for old_session in old_sessions
            old_sessions.destroy
          end

          cookies[:remember_me] = { :domain => SITE_DOMAIN, :value => nil, :expires => Time.now }
        end
      else
        session[:user] = NullUser.new
        session[:logged_in] = false

        old_sessions = RecoverySession.find( :all, :conditions => [ "remember_me = ?", cookies[:remember_me] ] )
        for old_session in old_sessions
          old_sessions.destroy
        end

        cookies[:remember_me] = { :domain => SITE_DOMAIN, :value => nil, :expires => Time.now }
      end
    else
      session[:user] = NullUser.new
      session[:logged_in] = false
      cookies[:remember_me] = { :domain => SITE_DOMAIN, :value => nil, :expires => Time.now }
    end
  end

  def urlnameify(text)
    # From http://textsnippets.com/posts/show/485
    t = Iconv.new('ASCII//TRANSLIT', 'utf-8').iconv(text)
    t = t.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
    (t.blank?) ? '-' : t 
  end

  # From http://www.37signals.com/rails/wiki/Authentication.html protected
  def authenticate
      unless session[:logged_in] == true 
        flash[:notice] = 'You must be logged in to do that'
        redirect_to :controller => "/home", :action => "index" 
        return false
      end     
  end

  def authenticate_admin
      unless session[:admin] == 1
        flash[:notice] = 'You must be logged in to do that'
        redirect_to :controller => "/home", :action => "index" 
        return false
      end
  end

  def is_spam?(author, text)
    @akismet = Akismet.new('676ea8', 'http://www.musicknows.com')

    # return true when API key isn't valid, YOUR FAULT!!
    return true unless @akismet.verifyAPIKey 

    # will return false, when everthing is ok and true when Akismet thinks the comment is spam. 
    return @akismet.commentCheck(
              request.remote_ip,            # remote IP
              request.user_agent,           # user agent
              request.env['HTTP_REFERER'],  # http referer
              '',                           # permalink
              'comment',                    # comment type
              author,                       # author name
              '',                           # author email
              '',                           # author url
              text,                         # comment text
              {})                           # other 
  end

  def submit_spam(author, text)
    @akismet = Akismet.new('676ea8', 'http://www.musicknows.com')

    # return true when API key isn't valid, YOUR FAULT!!
    return true unless @akismet.verifyAPIKey 

    return @akismet.submitSpam(
              request.remote_ip,            # remote IP
              request.user_agent,           # user agent
              request.env['HTTP_REFERER'],  # http referer
              '',                           # permalink
              'comment',                    # comment type
              author,                       # author name
              '',                           # author email
              '',                           # author url
              text,                         # comment text
              {})                           # other 
  end
end
