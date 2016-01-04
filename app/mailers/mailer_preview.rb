class MailerPreview < MailView
  def purchase_order
    Mailer.purchase_order(PurchaseOrder.open.first.id)
  end

  def join_hotel_invitation
    invitation = JoinHotelInvitation.create(sender: User.first, invitee: User.last, property: Property.first)
    Mailer.join_hotel_invitation(invitation.id)
  end
end
