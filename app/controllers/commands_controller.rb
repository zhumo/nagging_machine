class CommandsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :hook

  def stop
    @user = current_user
    @user.stop_all_nags
    redirect_to mynags_path
  end

  def restart
    @user = current_user
    @user.restart_all_nags
    redirect_to mynags_path
  end
  
  def done
    @nag = Nag.find(params[:id])
    @nag.declare_done
    redirect_to mynags_path
  end

  def hook
    Nag.route_incoming(params)
    render nothing: true
  end

end
