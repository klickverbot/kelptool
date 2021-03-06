# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # We have to exclude new and create from the global login requirement, otherwise these pages could never be reached. 
  before_filter :login_required, :except => [ :new, :create ]
  
  def new
    # Just render the template.
  end

  def create
    self.current_user = User.authenticate( params[ :login ], params[ :password ] )
    if logged_in?
      if params[ :remember_me ] == '1'
        current_user.remember_me unless current_user.remember_token?
        cookies[ :auth_token ] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[ :notice ] = 'Sie wurden erfolgreich angemeldet.'
    else
      flash[ :error ] = 'Anmeldung fehlgeschlagen.'
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[ :notice ] = 'Sie wurden abgemeldet.'
    redirect_back_or_default('/')
  end
end
