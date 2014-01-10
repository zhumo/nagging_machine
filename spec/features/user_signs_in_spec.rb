require 'spec_helper'

feature 'user signs in' do
  scenario 'user signs in with valid information' do
    user = FactoryGirl.create(:user)
    visit new_user_session_path

    fill_in "Phone Number", with: user.phone_number
    fill_in "Password", with: user.password

    click_on "Submit"

    expect(page).to have_content("My Nags")
    expect(page).to have_content(user.full_name)
  end

  scenario 'user submits phone number not found in database' do
    user = FactoryGirl.create(:user)
    visit new_user_session_path

    fill_in "Phone Number", with: "0987654321"
    fill_in "Password", with: "something"

    click_on "Submit"

    expect(page).to have_content("Invalid phone number or password")
  end

  scenario 'user submits password that is not valid' do
    user = FactoryGirl.create(:user)
    visit new_user_session_path

    fill_in "Phone Number", with: user.phone_number
    fill_in "Password", with: "098765"

    click_on "Submit"

    expect(page).to have_content("Invalid phone number or password")
  end

  scenario 'user submits invalid information' do
    visit new_user_session_path

    click_on "Submit"

    expect(page).to have_content("Invalid phone number or password")
  end
end
