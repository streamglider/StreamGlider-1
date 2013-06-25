class Users::PasswordsController < Devise::PasswordsController
  
  skip_before_filter :verify_authenticity_token, :only => [:create]
  skip_before_filter :require_no_authentication, :only => [:create]
  
  # POST /resource/password
  def create
    user = { :email => params[:email] }
    self.resource = resource_class.send_reset_password_instructions(user)

    if resource.reset_password_token
      render :json => { :status => "OK" }      
    else
      render :json => { :error => "Email is not found" }
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    @skip_nav = true
    render :template => 'users/passwords/edit'
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      flash_message = :updated_not_active
      flash[:notice] = 'Your password was changed successfully.'
      redirect_to password_reset_confirmed_url
    else
      @skip_nav = true      
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end

  def password_reset_confirmed
    @skip_nav = true
    render :template => 'users/passwords/password_reset_confirmed'  
  end  

end