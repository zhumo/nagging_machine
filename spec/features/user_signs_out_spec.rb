require 'spec_helper'

feature 'user signs out' do
  let(:user) {FactoryGirl.create(:user)}
  scenario 'user signs out from home page' do
    sign_in_as(user)
    visit root_path
    click_on "Sign Out"

    expect(page).to have_content("The Nagging Machine")
  end

  scenario 'user signs out from mynags page' do
    sign_in_as(user)
    click_on "Sign Out"

    expect(page).to have_content("The Nagging Machine")
  end
end
