require 'spec_helper'

feature 'user views the home page' do
  let(:user) {FactoryGirl.create(:user)}
  scenario 'user not signed in visits root path' do
    visit root_path

    expect(page).to have_content("Welcome")
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Sign In")
    expect(page).to_not have_content("Sign Out")
    expect(page).to_not have_content("Signed in as #{user.full_name}")
  end

  scenario "user who is signed in visits root path" do
    sign_in_as(user)

    visit root_path

    expect(page).to have_content("Welcome")
    expect(page).to have_content("Signed in as #{user.full_name}")
    expect(page).to have_content("Sign Out")
    expect(page).to_not have_content("Sign In")
    expect(page).to_not have_content("Sign Up")
  end


end
