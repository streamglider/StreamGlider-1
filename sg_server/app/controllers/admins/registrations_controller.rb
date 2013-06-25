class Admins::RegistrationsController < Devise::RegistrationsController
  
  skip_before_filter :require_no_authentication
    
  before_filter :authenticate_admin!, :only => :index
  
  def index
    unless current_admin
      redirect_to new_admin_session_url
      return
    end
    @admins = Admin.all
  end

  # POST /resource
  def create
    build_resource

    if resource.save
      redirect_to admins_url, :notice => 'New administrator account was created successfully!'
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
    
  # DELETE /resource
  def destroy
    if (Admin.count == 1)
      redirect_to admins_url, :alert => 'Delete failed, this administrator account is the last one.'
      return
    end
    
    admin = Admin.find params[:id]
    
    if admin == current_admin
      redirect_to admins_url, :alert => 'Delete failed, this is the account you are logged in with.'
      return      
    end
    
    admin.destroy
    
    redirect_to admins_url, :notice => 'Administrator account was deleted successfully'
  end
  
end