class Users::SessionsController < Devise::SessionsController
  
  skip_before_filter :verify_authenticity_token, :only => [:auth_token, :create]
  skip_before_filter :require_no_authentication
  
  def create
    u = params[:user]
    unless u
      render_json_error
      return
    end
    
    user = User.where(:email => u[:email]).first
    if user
      # sign out first
      signed_in = signed_in?(resource_name)
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)    
      
      #sign in     
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")      
      sign_in(resource_name, resource)
      
      render :json => { :token => resource.authentication_token }      
    else
      render :json => { :error => "Email is not found" }
    end
  end
  
  def auth_token
    u = params[:user]
    unless u
      render_json_error
      return
    end
      
    user = User.where(:email => u[:email]).first
    if user
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      sign_in(resource_name, resource)
      render :json => { :token => resource.authentication_token }      
    else
      user = User.new u
      
      if user.save
        sign_in(resource_name, user)
        render :json => { :token => user.authentication_token }
      else
        clean_up_passwords(user)
        render :json => { :error => "sign up failed" }
      end          
    end    
  end
  
end