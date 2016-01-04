class DevisePreview < MailView
  def confirmation_instructions
    user = User.where(:confirmed_at => nil).last || FactoryGirl.create(:user)
    Devise::Mailer.confirmation_instructions(user, user.confirmation_token)
  end
end
