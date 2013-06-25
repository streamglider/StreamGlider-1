class Users::RegistrationsController < Devise::RegistrationsController
  
  skip_before_filter :verify_authenticity_token, :only => [:create, :change_password]
  skip_before_filter :require_no_authentication
  
  before_filter :authenticate_user!, :only => :change_password
  
  before_filter :authenticate_admin!, :only => [:index, :destroy]
  skip_before_filter :authenticate_scope!, :only => [:destroy]
  
  def index
    unless current_admin
      redirect_to new_admin_session_url
      return
    end
    @users = User.all
  end
    
  def create
    build_resource

     if resource.save
       # sign out first
       Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)    
       
       sign_in(resource_name, resource)
       render :json => { :token => resource.authentication_token }
     else
       clean_up_passwords(resource)
       render :json => { :error => "This email has already been taken" }
     end    
  end
  
  def change_password
    old_pwd = params[:old_password]
    new_pwd = params[:new_password]
    
    if current_user && current_user.valid_password?(old_pwd)
      res = current_user.update_attributes :password => new_pwd, :password_confirmation => new_pwd
      render :json => { :status => "OK" }
    else
      render :json => { :error => 'Incorrect password' }
    end
        
  end
  
  # DELETE /resource
  def destroy
    unless current_admin
      redirect_to new_admin_session_url
      return
    end
    user = User.find params[:id]
    user.destroy
    redirect_to users_url
  end

end