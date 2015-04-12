class Api::NagsController < Api::ApiController
  before_filter :allow_cors

  def index
    render json: User.find(params[:user_id]).nags
  end

  def create
    @nag = Nag.create(nag_params)
    render json: @nag, status: :created
  end

  private
  def nag_params
    params.require('nag').permit(:contents, :user_id)
  end

end
