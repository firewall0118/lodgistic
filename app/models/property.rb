# == Schema Information
#
# Table name: properties
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  contact_name   :string(255)
#  street_address :string(255)
#  zip_code       :string(255)
#  city           :string(255)
#  email          :string(255)
#  phone          :string(255)
#  fax            :string(255)
#

class Property < ActiveRecord::Base
  has_many :user_roles
  has_many :join_hotel_invitations
  has_many :users, through: :user_roles
  has_many :gm_roles, -> { where(role_id: Role.gm.id)}, class_name: UserRole
  has_many :gms, through: :gm_roles, class_name: User, source: :user

  has_many :tags
  has_many :categories
  has_many :items
  has_many :locations
  has_many :lists
  has_many :vendors
  has_many :purchase_orders
  has_many :purchase_requests
  has_many :purchase_receipts

  has_one :corporate_connection, -> { where.not(state: Corporate::Connection::REJECTED_STATES) }, class_name: Corporate::Connection
  has_one :corporate, -> { where('corporate_connections.state = ?', :active) }, through: :corporate_connection

  validates :name, presence: true
  has_many :room_types

  def highest_gm_approval_limit
    Role.gm.user_roles.order(order_approval_limit: :desc).limit(1).pluck(:order_approval_limit).first
  end

  def proper_approvers total_price, current_user_id
    Role.gm.user_roles.where('order_approval_limit > ? and user_id != ?', total_price.to_f, current_user_id).includes(:user).map(&:user)
  end

  class << self
    def current_id=(id)
      RequestStore.store[:property_id] = id
    end

    def current_id
      RequestStore.store[:property_id]
    end

    def current
      Property.find(current_id) if current_id
    end
  end

  def switch!
    Property.current_id = self.id
    self
  end

  def run_block
    prev_property = Property.current
    self.switch!
    yield
  ensure
    prev_property.switch!
  end

  def run_block_with_no_property
    self.switch!
    yield
  ensure
    Property.current_id = nil
  end

end
