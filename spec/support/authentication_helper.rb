module AuthenticationHelper
  def sign_in_as(user)
    visit new_user_session_path

    fill_in "Phone Number", with: user.phone_number
    fill_in "Password", with: user.password

    click_on "Submit"
  end

  def sign_out
    visit mynags_path
    click_on "Sign Out"
  end
end
