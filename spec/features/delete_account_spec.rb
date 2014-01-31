require 'spec_helper'

feature 'delete user' do
  let(:user) {FactoryGirl.create(:user)}
  scenario 'user deletes his/her account' do
    sign_in_as(user)

    click_on("Edit Account")

    click_on("Delete Account")

    expect(page).to have_content("The Nagging Machine")
  end
end
