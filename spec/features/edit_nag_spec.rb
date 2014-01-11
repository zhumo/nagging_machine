#require 'spec_helper'
#
#feature 'user edits nag contents' do
#  let(:user) {FactoryGirl.create(:user)}
#  let(:nag) {user.nags.create(contents: "something")}
#  before :each do 
#    user
#    nag
#  end
#
#  scenario 'user inputs valid information' do
#    sign_in_as(user)
#    expect(page).to have_contents("something")
#
#    click_on "Edit"
#
#    fill_in "Contents", with: "something else"
#    
#    click_on "Submit"
#
#    expect(page).to have_content("something else")
#  end
#
#  scenario 'user inputs invalid information' do
#    sign_in_as(user)
#    click_on "Edit"
#
#    fill_in "Contents", with: ""
#
#    click_on "Submit"
#
#    expect(page).to have_content("can't be blank")
#  end
#end