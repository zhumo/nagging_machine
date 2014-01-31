require 'spec_helper'

feature 'user signs up' do
  before :each do
      ENV.stub(:[]).with("TWILIO_PHONE_NUMBER").and_return("+10985674321")
  end

  scenario 'user enters valid information' do
    expect(Message).to receive(:send_message).with("+11234567890",Message::WELCOME_MESSAGE)
    visit new_user_registration_path

    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Doe"
    fill_in "Phone Number", with: "1234567890"
    fill_in "Password", with: "123456", match: :prefer_exact
    fill_in "Password Confirmation", with: "123456", match: :prefer_exact

    click_on "Submit"

    user = User.find_by(phone_number: "1234567890")

    expect(Message).to receive(:send_message).with(user.full_phone_number,Message::PHONE_CONFIRMATION_MESSAGE)
    Message.route_incoming({From: user.full_phone_number, Body: user.confirmation_code})

    visit current_path

    user.reload
    
    expect(page).to have_content("John Doe")
    expect(page).to have_content("My Nags")
    expect(user.confirmation_code).to be_nil
    expect(user.confirmation_code_time).to be_nil
  end

  scenario 'user enters invalid information' do
    visit new_user_registration_path

    click_on "Submit"

    expect(page).to have_content("can't be blank")
    expect(page).to have_content("must be a ten-digit number")
  end

  scenario 'user enters valid information but the password and confirmation do not match' do
    visit new_user_registration_path
    
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Doe"
    fill_in "Phone Number", with: "1234567890"
    fill_in "Password", with: "123456", match: :prefer_exact
    fill_in "Password Confirmation", with: "1234567", match: :prefer_exact

    click_on "Submit"

    expect(page).to have_content("doesn't match Password")
  end
end

