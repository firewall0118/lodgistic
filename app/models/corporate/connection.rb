class Corporate::Connection < ActiveRecord::Base

  belongs_to :corporate
  belongs_to :property
  belongs_to :created_by, class_name: User

  validates :email, presence: true, confirmation: true
  validates_format_of :email, with: Devise.email_regexp

  attr_accessor :email_confirmation

  REJECTED_STATES = [:corporate_rejected, :property_rejected]

  state_machine initial: :new do
    event :approve do
      transition new: :corporate_approved, corporate_approved: :active
    end

    event :reject do
      transition new: :corporate_rejected, corporate_approved: :property_rejected
    end
  end

  def corp_user
    User.corporate.where(email: email).first
  end

end
