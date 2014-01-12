require 'spec_helper'

feature 'change password' do
  let(:user) {FactoryGirl.create(:user)}

  scenario 'user changes password' do
    sign_in_as(user)

    click_on "Change Password"

    fill_in "New Password", with: "somethingelse"
    fill_in "Password Confirmation", with: "somethingelse"
    fill_in "Current Password", with: user.password

    click_on "Submit"

    expect(page).to have_content("You updated your account successfully")
  end
end
