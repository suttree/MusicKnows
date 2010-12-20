class MemoryController < ApplicationController
  before_filter :authenticate, :except => [ :details, :list, :tag_list, :comment ]
  layout "main"

  def add
    @memory = Memory.new
    @bands = Array.new
    @venues = Array.new
    @page_title = 'Add your memory'
  end

  def edit
    # Pull out the memory and setup some variables
    # for user friendly display in the form
    @memory = Memory.find(params[:id])
    @photo = @memory.photo
    if @memory.user.id != session[:user].id
      redirect_to '/'
    else
      @bands = Array.new
      @venues = Array.new
      for tag in @memory.tags
        if tag.category == 'band'
          @bands << tag.name
        elsif tag.category == 'venue'
          @venues << tag.name
        end
      end
    end
  end

  def update
    # Whitelist the incoming data
    params[:memory][:title] = sanitize(params[:memory][:title], 'a href, b, br, i, p')
    params[:memory][:body] = sanitize(params[:memory][:body], 'a href, b, br, i, p')

    params[:band] = sanitize(params[:band], 'a href, b, br, i, p')
    params[:venue] = sanitize(params[:venue], 'a href, b, br, i, p')

    @user = User.find(session[:user].id)

    # Update the memory but keep the url name the same
    @memory = Memory.find(params[:id])
    @memory.user = @user
    @memory.title = params[:memory][:title]
    @memory.body = params[:memory][:body]
    @memory.year = params[:date][:year]
    @memory.month = params[:date][:month]
    @memory.day = params[:date][:day]

    if params[:photo][:uploaded_data] != ""
      photo = Photo.create params[:photo]
      @memory.photo = photo
    end

    # Tag it
    @memory.tags.clear

    bands = params[:band].split(',')
    for band in bands
      @memory.tags << create_tag( band, 'band' )
    end

    venues  = params[:venue].split(',')
    for venue in venues 
      @memory.tags << create_tag( venue, 'venue' )
    end

    if @memory.valid?
      @memory.save
      flash[:notice] = "Memory saved!"
      redirect_to :action => "details", :year => @memory.year, :month => @memory.month, :day => @memory.day, :url_name => @memory.url_name
    else
      # Pull apart the memory for display in the form once again
      @bands = Array.new
      @venues = Array.new
      for tag in @memory.tags
        if tag.category == 'band'
          @bands << tag.name
        elsif tag.category == 'venue'
          @venues << tag.name
        end
      end
      render :action => "edit"
    end
  end

  def save 
    @user = User.find(session[:user].id)

    # Whitelist the incoming data
    params[:memory][:title] = sanitize(params[:memory][:title], 'a href, b, br, i, p')
    params[:memory][:body] = sanitize(params[:memory][:body], 'a href, b, br, i, p')

    params[:band] = sanitize(params[:band], 'a href, b, br, i, p')
    params[:venue] = sanitize(params[:venue], 'a href, b, br, i, p')


    # Create the memory
    @memory = Memory.new
    @memory.user = @user
    @memory.title = params[:memory][:title]
    @memory.body = params[:memory][:body]

    if params[:photo][:uploaded_data] != ""
      photo = Photo.create params[:photo]
      @memory.photo = photo
    end

    # Yes, I should be using a single 'date' column in MySQL,
    # so that we can use the wide range of date and time functions
    # in our queries, but Ruby uses Date.parse to automatically create
    # Date objects from date columns. These don't play nicely with dates
    # such as 1975-00-00, which we want to support so that people can create
    # memories that only reference a year, or year and month, since people
    # are 'fuzzy' about dates, esepcially where music and alcohol are involved.
    @memory.year = params[:date][:year]
    @memory.month = params[:date][:month]
    @memory.day = params[:date][:day]

    # Make sure the url name is unique within the time period
    @memory.url_name = urlnameify(params[:memory][:title])

    options = {
      :url_name => @memory.url_name,
      :year => @memory.year,
      :month => @memory.month,
      :day => @memory.day,
    }

    while find_matching_memories( options ).size > 0
      @memory.url_name = '-' + @memory.url_name
      options[:url_name] = @memory.url_name
    end

    # Tag it
    bands = params[:band].split(',')
    for band in bands
      @memory.tags << create_tag( band, 'band' )
    end

    venues  = params[:venue].split(',')
    for venue in venues 
      @memory.tags << create_tag( venue, 'venue' )
    end

    if @memory.valid?
      @memory.save
      flash[:notice] = "Memory saved!"
      redirect_to :action => "details", :year => @memory.year, :month => @memory.month, :day => @memory.day, :url_name => @memory.url_name
    else
      @bands = Array.new
      @venues = Array.new
      for tag in @memory.tags
        if tag.category == 'band'
          @bands << tag.name
        elsif tag.category == 'venue'
          @venues << tag.name
        end
      end
      render :action => "add"
    end
  end

  def details
    @user = session[:user]

    options = {
      :url_name => params[:url_name],
      :year => params[:year],
      :month => params[:month],
      :day => params[:day],
    }

    @memory = Memory.find(  :first,
                            :conditions => create_where( options ),
                            :include => [ :user, :tags ]
                         )

    @nearby = Memory.nearby( params[:year] )
  end

  def list
    options = {
      :url_name => params[:url_name],
      :year => params[:year],
      :month => params[:month],
      :day => params[:day],
    }

    @memories = Memory.find(  :all,
                              :conditions => create_where( options ),
                              :include => [ :user, :tags ]
                         )

    @nearby = Memory.nearby( params[:year] )
  end

  def tag_list
    @tag = Tag.find_by_url_name(params[:tag])
    @memories = Memory.find(  :all,
                              :conditions => [ 'tags.url_name = ?', urlnameify(params[:tag]) ],
                              :include => [ :user, :tags ]
                            )

    @nearby = Memory.nearby( params[:year] )
  end

  def comment
    if session[:user].id
      user = User.find(session[:user].id)
      memory = Memory.find(params[:id])
      comment = Comment.new(params[:comment])
      comment.user = user
      memory.comments << comment
      memory.save
      flash[:notice] = "Comment added!"
      redirect_to :action => "details", :year => memory.year, :month => memory.month, :day => memory.day, :url_name => memory.url_name, :anchor => 'comment_' + comment.id.to_s
    else
      user = User.find_by_nickname('Anonymous')
      memory = Memory.find(params[:id])
      comment = Comment.new(params[:comment])
      comment.user = user

      # Use akismet to keep things in check!
      if is_spam?('Anonymous', comment.body)
        flash[:notice] = 'Sorry, but your comment looks like spam and has been rejected'
        redirect_to :action => "details", :year => memory.year, :month => memory.month, :day => memory.day, :url_name => memory.url_name
      else
        memory = Memory.find(params[:id])
        memory.comments << comment
        memory.save
        flash[:notice] = "Comment added!"
        redirect_to :action => "details", :year => memory.year, :month => memory.month, :day => memory.day, :url_name => memory.url_name, :anchor => 'comment_' + comment.id.to_s
      end
    end
  end

  def reply_comment
    @parent_comment = Comment.find(params[:id])
  end

  def edit_comment
    @comment = Comment.find(params[:id])
  end

  def update_comment
    # Whitelist the incoming data
    params[:comment].each do | key, value |
      params[:comment][key] = sanitize(value, 'a href, b, br, i, p')
    end

    comment = Comment.find(params[:id])
    comment.title = params[:comment][:title]
    comment.body = params[:comment][:body]
    comment.save
    flash[:notice] = "Comment edited!"
    redirect_to :action => "details", :year => comment.memory.year, :month => comment.memory.month, :day => comment.memory.day, :url_name => comment.memory.url_name
  end

  def report_spam
    if session[:user].admin?
      comment = Comment.find(params[:id])
      submit_spam('Anonymous',comment.body)
      comment.destroy
    end
    redirect_to :controller => 'home'
  end

  def add_friend
    friend_id = params[:id].split("_")[1]
    friend = Friend.find(friend_id)

    @memory = Memory.find(params[:memory_id])

    if @memory.friends.include?(friend)
      flash[:partial_notice] = friend.nickname + " already added!"
    else
      @memory.friends << friend
      @memory.save
    end

    render :partial => 'partials/friendslist'
  end

  def remove_friend
    # Remove the friend from the list and re-render it
    @memory = Memory.find(params[:memory_id])
    friend_to_remove = Friend.find(params[:id])
    
    current_friends = Array.new
    for friend in @memory.friends
      current_friends << friend
    end
    @memory.friends.clear

    for friend in current_friends
      if friend != friend_to_remove
        @memory.friends << friend
      end
    end

    @memory.save
    render :partial => 'partials/friendslist'
  end

  protected
  def create_where( options )
    if options[:day]
      if options[:url_name]
        conditions = [ 'memories.url_name = ? AND year = ? AND month = ? AND day = ?', options[:url_name], options[:year], options[:month], options[:day] ]
      else
        conditions = [ 'year = ? AND month = ? AND day = ?', options[:year], options[:month], options[:day] ]
      end
    elsif options[:month]
      if options[:url_name]
        conditions = [ 'memories.url_name = ? AND year = ? AND month = ?', options[:url_name], options[:year], options[:month] ]
      else
        conditions = [ 'year = ? AND month = ?', options[:year], options[:month] ]
      end
    else
      if options[:url_name]
        conditions = [ 'memories.url_name = ? AND year = ?', options[:url_name], options[:year] ]
      else
        conditions = [ 'year = ?', options[:year] ]
      end
    end
    conditions
  end

  def create_tag( item, category )
    tag = Tag.find_or_create_by_name_and_url_name_and_category(item.strip, urlnameify(item), category)
  end

  def find_matching_memories( options )
    Memory.find(  :all, :conditions => create_where( options ) )
  end
end
