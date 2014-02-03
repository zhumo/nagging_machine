class NagsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :phone_confirmation_redirect

  def index
    @user = User.find(current_user.id)
    @nags = @user.nags.where(status: "active").order(created_at: :desc)
  end

  def new
    @nag = Nag.new
  end

  def create
    @nag = current_user.nags.build(nag_params)

    if @nag.save
      @nag.update_attribute(:next_ping_time, Time.now)
      @nag.generate_next_ping_time
      Nag.populate_sidekiq
      redirect_to mynags_path
    else
      render :new
    end
  end

  def edit
    @nag = Nag.find(params[:id])
  end

  def update
    @nag = Nag.find(params[:id])

    if @nag.update(nag_params)
      redirect_to mynags_path
    else
      render :edit
    end
  end

  private

  def nag_params
    params.require('nag').permit(:contents)
  end
end
