class PermissionsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def permission_params
    params.require(:permission).permit :role_id, :name, :action, :subject_type, :subject_id, :other_id, :description
  end
  private :permission_params

  def subjects
    klass = params[:class].camelize.constantize
    @subjects = klass.all.map {|s| {id: s.id, name: s.to_s}}
    respond_with @subjects
  end

  def index
    @permissions = Permission.where(role_id: current_property.role_ids)
    respond_with @permissions
  end

  # def show
  #   @permission = Permission.find(params[:id])
  #   respond_with @permission
  # end

  def new
    @permission = Permission.new
    respond_with @permission
  end

  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      redirect_to permissions_path, notice: 'Permission was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @permission = Permission.find(params[:id])
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update_attributes(permission_params)
      redirect_to permissions_path, notice: 'Permission was successfully updated.'
    else
      render action: 'edit', error: @permission.errors.full_messages.to_sentence
    end
  end

  def destroy
    @permission = Permission.find(params[:id])
    @permission.destroy
    redirect_to permissions_path
  end
end
