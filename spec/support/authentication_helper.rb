module AuthenticationHelper
  def sign_in_as(user)
    visit new_user_session_path

    fill_in "Phone Number", with: user.phone_number
    fill_in "Password", with: user.password

    click_on "Submit"
  end

  def confirm_user(user)
    expect(Message).to receive(:send_message).with(user.full_phone_number, Message::PHONE_CONFIRMATION_MESSAGE)

    Message.route_incoming({From: user.full_phone_number, Body: user.confirmation_code})
  end

  def confirm_and_sign_in_as(user)
    confirm_user(user)
    sign_in_as(user)
  end

  def sign_out
    visit mynags_path
    click_on "Sign Out"
  end
end
