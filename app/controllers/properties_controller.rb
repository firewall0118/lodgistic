class PropertiesController < ApplicationController
  respond_to :json

  def show
    @property = user_properties.find(params[:id])

    session[:property_id] = @property.try(:id)
    info = t("controllers.properties.property_changed", name: @property.name)

    flash[:info]  = t("controllers.properties.content_may_have_changed")
    respond_with @property
  end

  def update
    authorize! :settings, Property
    @property = current_user.all_properties.find(params[:id])
    @property.update_attributes(property_attributes)
    flash[:notice] = t("controllers.properties.property_updated")

    redirect_to :property_settings
  end

  def index
    @properties = user_properties
    session[:property_id] = nil
    flash[:info]  = t("controllers.properties.no_properties_selected")
    respond_with @properties
  end

  private

  def property_attributes
    params.require(:property).permit(:vpt_partner_id, :vpt_username, :vpt_password)
  end
end
