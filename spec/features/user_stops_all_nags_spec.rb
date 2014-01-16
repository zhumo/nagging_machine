require 'spec_helper'

feature 'user stops all nags' do
  scenario 'user clicks on stop all nags' do
    user = FactoryGirl.create(:user, status: "active")
    nag = user.nags.create(contents: "nag")
    sign_in_as(user)

    expect(page).to have_content("active")
    
    click_on "Stop All Nags"

    expect(page).to have_content("stopped")
    expect(page).to_not have_content("active")
  end

end
