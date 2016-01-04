class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :property

  validates :property_id, uniqueness: {scope: :user_id, message: "A user can only have one role per property" }
  validates :role_id, presence: true

  default_scope { where(property_id: Property.current_id) }
end
