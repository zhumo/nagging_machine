require 'spec_helper'

feature 'user declares nag done' do
  let(:user) {FactoryGirl.create(:user)}
  let(:nag) {user.nags.first}
  before :each do
    user.nags.create(contents:"nag")
    user
  end

  scenario 'user clicks "done"' do
    sign_in_as(user)

    click_on "Done"
    
    expect(page).to_not have_content(nag.contents)
    expect(nag.status).to eq("done")
  end

end
