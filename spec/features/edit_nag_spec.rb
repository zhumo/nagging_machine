require 'spec_helper'

feature 'user edits nag contents' do
  let(:user) {FactoryGirl.create(:user, status: "active")}
  let(:nag) {user.nags.create(contents: "something")}
  before :each do 
    user
    nag
  end

#  scenario 'user inputs valid information' do
#    sign_in_as(user)
#    expect(page).to have_content("Something")
#
#    click_on "Edit"
#
#    fill_in "Remind me to...", with: "something else"
#    
#    click_on "Submit"
#
#    expect(page).to have_content("Something else")
#  end
#
#  scenario 'user inputs invalid information' do
#    sign_in_as(user)
#    click_on "Edit"
#
#    fill_in "Remind me to...", with: ""
#
#    click_on "Submit"
#
#    expect(page).to have_content("can't be blank")
#  end
end
