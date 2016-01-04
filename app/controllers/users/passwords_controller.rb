class Users::PasswordsController < Devise::PasswordsController
  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    Property.current_id = resource.all_properties.first.id

    super
  end

  private :resource_params

  protected
  def after_resetting_password_path_for(resource)
    signed_in_root_path(resource)
  end
end
