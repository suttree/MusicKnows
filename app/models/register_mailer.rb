class RegisterMailer < ActionMailer::Base

  def activate(register)
    @subject    = 'Activate your Music Knows account'
    @recipients = register.email
    @from       = 'noreply@musicknows.com'
    @body['register'] = register 
  end

  def welcome(register)
    @subject    = 'Welcome to Music Knows'
    @recipients = register.email
    @from       = 'noreply@musicknows.com'
    @body['register'] = register 
  end

  def password(user)
    @subject    = 'New Music Knows Password'
    @recipients = user.email
    @from       = 'noreply@musicknows.com'
    @body['user'] = user
  end

  def contact(message,email)
    @subject    = 'Music Knows Contact'
    @recipients = 'duncan.gough@gmail.com'
    @from       = 'noreply@musicknows.com'
    @body['message'] = message
    @body['email'] = email
  end
end
