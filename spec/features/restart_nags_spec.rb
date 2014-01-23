require 'spec_helper'

feature 'restart nags' do
    let(:user) {FactoryGirl.create(:user)}
    let(:nag) {FactoryGirl.create(:nag, user: user)}

    before :each do
      user
      nag
    end

  scenario 'if user\'s status is stopped, user restarts nags' do
    user.update_attribute(:status, "stopped")
    sign_in_as(user)

    expect(page).to have_content("Restart Nags")
    expect(page).to_not have_content("Stop All Nags")
    
    click_on "Restart Nags"

    expect(page).to have_content("Stop All Nags")
    expect(page).to_not have_content("Restart Nags")
  end

  scenario 'if user\'s status is active, there is no restart button' do
    sign_in_as(user)

    expect(page).to_not have_content("Restart Nags")
    expect(page).to have_content("Stop All Nags")
  end
end
