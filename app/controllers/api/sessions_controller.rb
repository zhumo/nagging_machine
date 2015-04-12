class Api::SessionsController < Api::ApiController
  before_filter :allow_cors

  def create
    @user = User.find_by(phone_number: params[:phone_number])
    if @user.present?
      render json: @user.id
    else
      head :forbidden
    end
  end

end
