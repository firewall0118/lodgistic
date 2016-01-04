# == Schema Information
#
# Table name: permissions
#
#  id           :integer          not null, primary key
#  role_id      :integer
#  subject_type :string(255)
#  subject_id   :integer
#  action       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Permission < ActiveRecord::Base
  MODELS = ['Category', 'List', 'Location', 'Unit', 'Vendor', 'PurchaseOrder', 'User']
  ACTIONS = [['Read', :read], ['Create', :create], ['Update', :update], ['Destroy', :destroy], ['All', :manage]]

  belongs_to :role
  belongs_to :subject, polymorphic: true

  validates :role_id, :action, :subject_type, presence: true
  validates :action, inclusion: {in: ACTIONS.map(&:second)}
  validates :subject_type, inclusion: {in: MODELS}

  def self.models
    MODELS
  end

  def self.actions
    ACTIONS
  end

  def action
    read_attribute(:action).try :to_sym
  end

  def action=(value)
    write_attribute :action, value
  end

  def subject_class
    self.subject_type.constantize
  end

  def subject_resource
    self.subject_type.pluralize.underscore.to_sym
  end
end
