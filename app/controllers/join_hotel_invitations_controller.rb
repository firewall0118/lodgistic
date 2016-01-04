class JoinHotelInvitationsController < ApplicationController
  before_filter :authenticate_user!

  def accept
    invitation = JoinHotelInvitation.find(params[:id])
    if current_user == invitation.invitee
      invitation.property.run_block do
        user_params = ActionController::Parameters.new(invitation.params).permit!
        current_user.reload.update(user_params)
      end

      redirect_to '/', notice: "You now have access to #{invitation.property.name}"
      invitation.destroy
    else
      raise "Attempted to access an invitation they didn't own"
    end
  end

  def destroy
    invitation = JoinHotelInvitation.find(params[:id])
    invitation.destroy
    redirect_to users_path
  end
end
