require 'spec_helper'
#feature 'change phone number' do
#  context 'user\'s phone number is confirmed and he/she is logged in' do
#    before(:each) do
#      @user = FactoryGirl.create(:user)
#      sign_in_as(@user)
#    end
#
#    scenario 'user inputs valid information and sends back the correct code' do
#      click_on "Change My Phone Number"
#
#      expect(page).to have_content("Change Phone Number")
#      new_phone_number = "0987654321"
#
#      fill_in "New Phone Number", with: new_phone_number
#      fill_in "Password", with: @user.password
#
#      click_on "Submit"
#
#      @user.reload
#
#      expect(@user.status).to eq("awaiting confirmation")
#      expect(@user.confirmation_code).to be_present
#      expect(@user.confirmation_code_time).to be_present
#      expect(@user.phone_number_temp).to eq(new_phone_number)
#      expect(page).to have_content("Confirm Phone Number")
#      expect(page).to have_content(new_phone_number)
#      expect(page).to have_content(@user.confirmation_code)
#
#      expect(Message).to receive(:send_message).with(new_phone_number, Message::PHONE_CHANGE_CONFIRMATION_MESSAGE)
#
#      Message.route_incoming({From: new_phone_number, Body: @user.confirmation_code})
#
#      @user.reload
#
#      expect(@user.phone_number).to eq(new_phone_number)
#      expect(@user.status).to eq("active")
#      expect(@user.confirmation_token).to be_nil
#      expect(@user.confirmation_token_time).to be_nil
#    end
#
#    scenario 'user inputs invalid information'
#
#    scenario 'user inputs valid information and sends back the wrong code'
#
#    scenario 'user changes his/her mind and cancels out of change phone process'
#  end
#end
