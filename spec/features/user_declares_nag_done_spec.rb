require 'spec_helper'

feature 'user declares nag done' do

  scenario 'user clicks "done"', js: true do
    user = FactoryGirl.create(:user)
    nag = FactoryGirl.create(:nag, user: user)
#    visit new_user_session_path
#
#    fill_in "Phone Number", with: user.phone_number
#    fill_in "Password", with: user.password
#
#    save_and_open_page
    sign_in_as(user)
    expect(Nag).to receive(:populate_sidekiq)

    check "Done"

    expect(page).to_not have_content(nag.contents)
    expect(Nag.first.status).to eq("done")
  end

end
