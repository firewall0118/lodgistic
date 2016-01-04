class Users::SessionsController < Devise::SessionsController
  after_filter :save_email_in_cookies, only: :create
  after_filter :destroy_email_in_cookies, only: :destroy
  skip_before_filter :scope_current_property

  def save_email_in_cookies
    cookies[:user_email] = { value: resource.email, expires: 1.day.from_now }
  end

  def destroy_email_in_cookies
    cookies.delete(:user_email)
  end

  def switch_current_property
    if params[:new_property_id] == 'corporate' && current_user.corporate_id?
      session[:property_id] = nil
      flash[:notice] = I18n.t('users.sessions.property_changed_success_message', hotel_name: current_user.corporate.name)
    else
      property = current_user.all_properties.find_by_id(params[:new_property_id])
      if property
        session[:property_id] = property.id
        # Property.current_id   = property.id
        flash[:notice] = I18n.t('users.sessions.property_changed_success_message', hotel_name: property.name)
      else
        flash[:error] = I18n.t('users.sessions.property_changed_error_message')
      end
    end
    redirect_to authenticated_root_path
  end
end
