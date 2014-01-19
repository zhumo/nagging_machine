require 'spec_helper'

feature 'user stops all nags' do
  scenario 'user clicks on stop all nags' do
    user = FactoryGirl.create(:user)
    nag = FactoryGirl.create(:nag, user: user, next_ping_time: Time.local(2020,1,1,12))
    sign_in_as(user)

    expect(page).to have_content("active")
    
    click_on "Stop All Nags"

    expect(page).to have_content("stopped")
    expect(page).to_not have_content("active")
  end

end
