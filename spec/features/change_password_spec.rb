require 'spec_helper'

feature 'Edit account' do
  let(:user) {FactoryGirl.create(:user, status: "active")}

  scenario 'user changes password' do
    sign_in_as(user)

    click_on "Edit Account"

    within ".user_password" do
      fill_in "New Password (leave blank if unnecessary)", with: "somethingelse"
    end
    within ".user_password_confirmation" do
      fill_in "New Password Confirmation", with: "somethingelse"
    end
    fill_in "Current Password", with: user.password

    click_on "Submit"

    click_on "Sign Out"

    click_on "Sign In"

    fill_in "Phone Number", with: user.phone_number
    fill_in "Password", with: "somethingelse"

    click_on "Submit"

    expect(page).to have_content(user.full_name)
    expect(page).to have_content(user.formatted_phone_number)
    expect(page).to have_content("My Nags")
  end

  scenario 'user changes name' do
    sign_in_as(user)

    click_on "Edit Account"

    fill_in "First Name", with: "Mo"
    fill_in "Last Name", with: "Zhu"
    fill_in "Current Password", with: user.password

    click_on "Submit"

    expect(page).to have_content("Mo Zhu")
    expect(page).to_not have_content(user.full_name)
  end
end
