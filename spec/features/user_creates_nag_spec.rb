require 'spec_helper'

feature "user creates a new nag" do
  before(:each) do
    user = FactoryGirl.create(:user, status: "active")
    sign_in_as(user)
    click_on "New Nag"
  end

  scenario "enters valid information" do
    fill_in "Remind me to...", with: "awesome"

    click_on "Submit"

    expect(page).to have_content("Awesome")
  end

  scenario "enters invalid information" do
    fill_in "Remind me to...", with: ""

    click_on "Submit"

    expect(page).to have_content("is too short")
  end
end
