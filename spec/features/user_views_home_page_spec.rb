require 'spec_helper'

feature 'user views the home page' do
  let(:user) {FactoryGirl.create(:user)}
  scenario 'user not signed in visits root path' do
    visit root_path

    expect(page).to have_content("The Nagging Machine")
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Sign In")
  end

  scenario "user who is signed in visits root path" do
    sign_in_as(user)

    visit root_path

    expect(page).to have_content("My Nags")
    expect(page).to have_content(user.full_name)
    expect(page).to have_content(user.formatted_phone_number)
  end


end
