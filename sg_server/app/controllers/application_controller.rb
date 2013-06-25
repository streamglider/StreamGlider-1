class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def render_error
    redirect_to root_path
  end
  
  def render_json_error(message='error')
    render :json => { :error => message }
  end
  
protected 

  def should_be_authenticated
    if !user_signed_in? && !admin_signed_in?
      if request.format == 'application/json'
        authenticate_user!
      else
        authenticate_admin!        
      end
    end
  end
    
end

