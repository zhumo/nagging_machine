class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super
  end

  def password_confirmation
    current_user.generate_confirmation_code
  end
end
