require 'spec_helper'

feature 'user stops all nags' do
  let(:user) {FactoryGirl.create(:user)}
  let(:nag) {user.nags.create(contents: "nag")}
  before :each do
    user
    nag
  end

  scenario 'user clicks on stop all nags' do
    sign_in_as(user)

    expect(page).to have_content("active")

    click_on "Stop All Nags"

    expect(page).to have_content("stopped")
  end

end
