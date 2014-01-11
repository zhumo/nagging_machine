class NagsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = User.find(current_user.id)
    @nags = @user.nags.where(status: "active")
  end

  def new
    @nag = Nag.new
  end

  def create
    @nag = current_user.nags.build(nag_params)

    if @nag.save
      redirect_to mynags_path
    else
      render :new
    end
  end

  def done
    @nag = Nag.find(params[:id])
    @nag.declare_done
    redirect_to mynags_path
  end

  private

  def nag_params
    params.require('nag').permit(:contents)
  end
end
