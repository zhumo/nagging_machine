require 'spec_helper'

feature "user creates a new nag" do
  before(:each) do
    user = FactoryGirl.create(:user)
    sign_in_as(user)
    click_on "New Nag"
  end

  scenario "enters valid information" do
    fill_in "Contents", with: "awesome"

    click_on "Submit"
    
    expect(page).to have_content("awesome")
  end

  scenario "enters invalid information" do
    fill_in "Contents", with: ""

    click_on "Submit"

    expect(page).to have_content("can't be blank")
  end
end
