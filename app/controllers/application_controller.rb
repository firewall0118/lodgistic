class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :scope_current_property
  before_filter :set_cache_buster

  protected

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def scope_current_property
    Property.current_id = current_property.try(:id) if user_signed_in?
  end

  rescue_from CanCan::AccessDenied do |e|
    flash[:alert] = e.message

    if request.env["HTTP_REFERER"]
      redirect_to :back
    else
      redirect_to '/'
    end
  end

  def user_properties
    @user_properties ||= current_user.all_properties
  end
  helper_method :user_properties

  def current_corporate
    current_user.corporate
  end
  helper_method :current_corporate

  def current_property
    # return nil if current_user.corporate? && session[:property_id].blank?
    if current_user.corporate?
      if session[:property_id]
        return user_properties.where(id: session[:property_id]).first
      else
        return nil
      end
    end

    @current_property ||= if user_properties.one? || session[:property_id].nil?
      user_properties.first
    else
      user_properties.where(id: session[:property_id]).first
    end
    raise I18n.t('controllers.application.no_properties_for_user') if @current_property.nil?
    session[:property_id] = @current_property.id
    @current_property
  end
  helper_method :current_property

  def selected_property
    @selected_property ||= Property.first
  end
  helper_method :selected_property

  def after_sign_in_path_for(user)
    sign_in_url = url_for(action: 'new', controller: 'sessions', only_path: false, protocol: 'http')
    if user.corporate?
      corporate_root_path
    else
      if request.referer == sign_in_url
        super
      else
        stored_location_for(user) || request.referer || dashboard_path
      end
    end
  end


  def setup_active?
    vendors_active? || categories_active? || locations_active? || departments_active?
  end
  helper_method :setup_active?


  def favorie_reports_active?
    reports_active? and params['action'] == 'favorites'
  end
  helper_method :favorie_reports_active?

  MENU_ITEMS = %W[departments categories vendors users lists locations items purchase_requests purchase_orders reports budgets] 

  MENU_ITEMS.each do |item|
    method_name = "#{item}_active?"
    define_method method_name do
      params[:controller] == item
    end
    helper_method method_name
  end

end
