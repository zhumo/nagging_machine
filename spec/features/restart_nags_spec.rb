require 'spec_helper'

feature 'restart nags' do
    let(:user) {FactoryGirl.create(:user)}
    let(:nag) {user.nags.create(contents: "nag")}

    before :each do
      user
      nag
    end

  scenario 'if user\'s status is stopped, user restarts nags' do
    user.update_attribute(:status, "stopped")
    sign_in_as(user)

    expect(page).to have_content("stopped")
    expect(page).to_not have_content("active")
    
    click_on "Restart All Nags"

    expect(page).to have_content("active")
    expect(page).to_not have_content("stopped")
  end

  scenario 'if user\'s status is active, there is no restart button' do
    sign_in_as(user)

    expect(page).to have_content("active")
    expect(page).to_not have_content("stopped")
    expect(page).to_not have_content("Restart All Nags")
  end
end
