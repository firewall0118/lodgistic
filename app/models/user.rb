class User < ActiveRecord::Base
  acts_as_paranoid

  devise :database_authenticatable, :recoverable, :trackable, :validatable, :confirmable
  mount_uploader :avatar, AvatarUploader

  belongs_to :corporate
  belongs_to :created_by_user, class_name: 'User' 
  has_and_belongs_to_many :old_roles

  has_many :user_roles
  has_many :roles, through: :user_roles

  has_many :properties, through: :user_roles
  has_one :current_property_user_role, class_name: 'UserRole'
  has_one :current_property_role, through: :current_property_user_role, source: :role
  delegate :title, to: :current_property_user_role, allow_nil: true
  delegate :title=, to: :current_property_user_role, allow_nil: true
  delegate :order_approval_limit, to: :current_property_user_role, allow_nil: true
  delegate :order_approval_limit=, to: :current_property_user_role, allow_nil: true

  has_many :report_favoritings
  has_many :favorite_reports, through: :report_favoritings, source: :report
  has_many :departments_users
  has_many :departments, through: :departments_users
  has_many :categories, through: :departments
  has_many :notifications
  has_many :purchase_orders
  has_many :purchase_requests
  has_many :budgets

  accepts_nested_attributes_for :current_property_user_role

  validates :name, presence: true
  # validates :order_approval_limit, presence: true
  validates :current_property_user_role, presence: true, if: lambda{ !!Property.current_id }
  validates :corporate_id, presence: true, unless: lambda{ !!Property.current_id }
  validate :at_least_one_department, if: lambda{ !!Property.current_id }

  def at_least_one_department
    errors.add :department_ids, 'at least one should be selected' if department_ids.empty?
  end
  
  # Overwrite only_deleted, pending resolution of https://github.com/radar/paranoia/issues/62
  scope :only_deleted, -> { all.tap { |x| x.default_scoped = false }.where{deleted_at != nil} }
  scope :corporate, -> { where.not(corporate_id: nil) }

  def active_for_authentication?
    super && !deleted_at
  end

  def deleted?
    !!deleted_at
  end

  def inactive_message
    deleted? ? :deleted : super
  end

  def activate!
    self.restore!
  end

  def inactivate!
    self.email = "inactive_" + self.email
    self.save
    self.destroy
  end

  def default_hotel_name
    all_properties.first.name
  end

  def first_name
    first, last = name.split(' ')
    first
  end

  def first_name_last_initial
    first, last = name.split(' ')
    "#{first} #{last[0].upcase}."
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def corporate?
    !Property.current_id && corporate_id?
  end

  def all_properties
    if corporate_id?
      corporate.properties # corporate user has access to all properties of his Corporate by default
    else
      Property.where(id: UserRole.unscoped.where(user_id: self.id).pluck(:property_id))
    end
  end

  def current_property
    return nil unless current_property_user_role.present?
    current_property_user_role.property
  end

  def pusher_id
    "#{Rails.env}_#{id}"
  end
end
