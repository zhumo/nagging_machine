class CommandsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :hook

  def stop
    @user = current_user
    @user.update_attribute(:status, "stopped")
    redirect_to mynags_path
  end

  def restart
    @user = current_user
    @user.update_attribute(:status, "active")
    redirect_to mynags_path
  end
  
  def done
    binding.pry
    @nag = Nag.find(params[:id])
    @nag.declare_done
    redirect_to mynags_path
  end

  def hook
    Nag.route_incoming(params)
    render nothing: true
  end

end
