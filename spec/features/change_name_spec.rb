require 'spec_helper'

feature 'Edit account' do
  let(:user) {FactoryGirl.create(:user)}

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
