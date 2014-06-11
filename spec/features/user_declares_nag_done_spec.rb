require 'spec_helper'

feature 'user declares nag done' do

  scenario 'user clicks "done"', js: true do
    user = FactoryGirl.create(:user)
    nag = FactoryGirl.create(:nag, user: user)
    sign_in_as(user)
    expect(Nag).to receive(:populate_sidekiq)

    check "Done"

    expect(page).to_not have_content(nag.contents)
    expect(Nag.first.status).to eq("done")
  end

end
