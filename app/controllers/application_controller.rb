class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def password_confirmation_redirect
    if current_user.awaiting_confirmation?
      redirect_to password_confirmation_path
    end
  end

  protected
  
  def after_sign_in_path_for(user)
    mynags_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name]
  end

end
