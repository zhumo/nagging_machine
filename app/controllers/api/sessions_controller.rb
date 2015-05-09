class Api::SessionsController < Api::ApiController
  before_filter :allow_cors

  def create
    @user = User.find_by(phone_number: params[:phone_number])
    if @user.present?
      if @user.valid_password?(params[:password])
        @user.update_attribute(:auth_token, SecureRandom.hex(10))
        render json: {auth_token: @user.auth_token}, status: :ok
      else
        head :forbidden
      end
    else
      head :not_found
    end
  end

end
