class CommandsController < ApplicationController
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
    @nag = Nag.find(params[:id])
    @nag.declare_done
    redirect_to mynags_path
  end

end
