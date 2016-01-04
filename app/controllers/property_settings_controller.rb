class PropertySettingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :settings, Property
    add_breadcrumb t("controllers.property_settings.property_settings")
  end
end
