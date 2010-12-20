class HelpController < ApplicationController
  layout "main"

  def index
  end

  def about
  end

  def contact
  end

  def contact_send
    # Oh lazy, lazy, lazy..
		RegisterMailer::deliver_contact(params[:message], params[:email])
		redirect_to :action => 'thankyou'
  end

  def thankyou
  end
end
