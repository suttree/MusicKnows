class RegisterController < ApplicationController
  layout "main"

  def index
    session[:register] = nil
    @register = Register.new
    render :action => "index"
  end

  def validate
    @register = Register.new(params[:register])

    if @register.valid?
      session[:register] = @register
      redirect_to :action => 'done'
    else
      render :action => 'index'
    end
  end

  def done
    @register = Register.new(params[:register])

    # Add back the details from step one
    @register.email = session[:register].email
    @register.nickname = session[:register].nickname
    @register.password = session[:register].password

    # The following from http://www.bigbold.com/snippets/posts/show/491
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    activation_code = ""
    1.upto(10) { |i| activation_code << chars[rand(chars.size-1)] }
    @register.activation_code = activation_code

    @register.save

    RegisterMailer.deliver_activate(@register)

    # Automatically log the user in, but don't set a remember me
    # cookie so that the user can test the site out, but will need
    # to check remember to login in future.
    session[:user] = User.find_by_email(@register.email)

    redirect_to :action => 'thankyou'
  end

  def thankyou
    render :action => 'thankyou'
  end

  def activate
    @register = Register.find_by_activation_code(params[:id])
    @register.activation_date = Time.now  
    @register.save

    if @register.valid?
      RegisterMailer.deliver_welcome(@register)
      redirect_to :action => 'welcome'
    else
      flash[:notice] = "Can't find a user with that activation code"
      render :action => 'activate'
    end
  end

  def welcome
    render :action => 'welcome'
  end
end
