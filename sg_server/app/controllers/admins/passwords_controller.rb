class Admins::PasswordsController < Devise::PasswordsController
  
  skip_before_filter :require_no_authentication, :only => [:edit, :update]
  
  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    current_admin.reset_password_token = Admin.reset_password_token
    current_admin.reset_password_sent_at = Time.now.utc
    current_admin.save
    self.resource = current_admin
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      sign_in(resource_name, resource)
      redirect_to admins_url, :notice => 'Your password was changed successfully!'
    else
      respond_with resource
    end
  end
  
end