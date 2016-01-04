class JoinHotelInvitation < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :invitee, class_name: 'User'
  belongs_to :property

  serialize :params, Hash
end
