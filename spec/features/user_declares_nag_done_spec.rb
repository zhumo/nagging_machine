require 'spec_helper'

feature 'user declares nag done' do
  let(:user) {FactoryGirl.create(:user)}
  let(:nag) {user.nags.create(contents: "nag")}
  before :each do
    nag
    user
  end

  scenario 'user clicks "done"' do
    sign_in_as(user)
    
    click_on "Done"
    
    expect(page).to_not have_content(nag.contents)
  end

end
