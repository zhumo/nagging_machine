class CommandsController < ApplicationController
  def stop
    @user = current_user
    @user.update_attribute(:status, "stopped")
    redirect_to mynags_path
  end
end
