class HomeController < ApplicationController
  layout "home_page"

  def index
    if user_signed_in?
      redirect_to mynags_path
    end
  end
end
