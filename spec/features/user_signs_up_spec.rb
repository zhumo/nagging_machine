require 'spec_helper'

feature 'user signs up' do
  scenario 'user enters valid information' do
    visit new_user_registration_path

    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Doe"
    fill_in "Phone Number", with: "1234567890"
    fill_in "Password", with: "123456", match: :prefer_exact
    fill_in "Password Confirmation", with: "123456", match: :prefer_exact

    click_on "Submit"

    expect(page).to have_content("John Doe")
    expect(page).to have_content("My Nags")
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

