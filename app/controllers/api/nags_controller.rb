class Api::NagsController < Api::ApiController
  before_filter :allow_cors

  def index
    render json: User.find_by(auth_token: params[:auth_token]).nags
  end

  def create
    @nag = Nag.create(nag_params)
    render json: @nag, status: :created
  end

  def done
    @nag = Nag.find_by(id: params[:id])
    if @nag.present?
      @nag.declare_done
      head :ok
    else
      head :not_found
    end
  end

  private
  def nag_params
    params.require('nag').permit(:contents, :user_id)
  end

end
