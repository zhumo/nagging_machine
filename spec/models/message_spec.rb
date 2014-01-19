require 'spec_helper'

describe Message do
  describe "route_incoming" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @unconfirmed_user = FactoryGirl.create(:unconfirmed_user)
    end

    it "should send the unknown_user_message if the user's phone number is not registered. This should also change the user's status to active" do
      expect(Message).to receive(:send_message).with("+10987654321", Message::UNKNOWN_USER_MESSAGE)
      params = {From: "+10987654321", Body: "test"}
      Message.route_incoming(params)
    end

    it "should send the phone confirmation message if the message is a 4-digit number and the message matches the account's confirmation token and the message is sent within 1 hour of the confirmation code creation. This should make the confirmation code empty" do
      expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::PHONE_CONFIRMATION_MESSAGE)
      params = {From: @unconfirmed_user.full_phone_number, Body: @unconfirmed_user.confirmation_code}
      Message.route_incoming(params)

      @unconfirmed_user.reload

      expect(@unconfirmed_user.confirmation_code).to be_nil
      expect(@unconfirmed_user.confirmation_code_time).to be_nil
    end

    it "should send the incorrect confirmation code message if the message is a 4-digit number and the message does not match the account's confirmation token and the message is sent within 1 hour of the confirmation code's creation. This should reset the confirmation code" do
      time = @unconfirmed_user.confirmation_code_time

      expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::INCORRECT_CONFIRMATION_CODE_MESSAGE)
      params = {From: @unconfirmed_user.full_phone_number, Body: "4321"}
      Message.route_incoming(params)

      @unconfirmed_user.reload

      expect(@unconfirmed_user.confirmation_code).to_not eq("1234")
      expect(@unconfirmed_user.confirmation_code_time).to_not eq(time)
    end

    it "should send the incorrect confirmation code message if the message is a 4-digit number and the message does match the account's confirmation token and the message is sent more than 1 hour of the confirmation code's creation. This should reset the confirmation code" do
      time = @unconfirmed_user.confirmation_code_time

      expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::INCORRECT_CONFIRMATION_CODE_MESSAGE)
      params = {From: @unconfirmed_user.full_phone_number, Body: "4321"}
      Message.route_incoming(params)

      @unconfirmed_user.reload

      expect(@unconfirmed_user.confirmation_code).to_not eq("1234")
      expect(@unconfirmed_user.confirmation_code_time).to_not eq(time)
    end

    it "should send the unconfirmed phone number message if the user's account is awaiting confirmation and the user sends a message" do
      expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::UNCONFIRMED_PHONE_NUMBER_MESSAGE)
      params = {From: @unconfirmed_user.full_phone_number, Body: "test"}
      Message.route_incoming(params)
    end

    it "should send the nag done message and declare the user's last nag to be done if the user sends 'done'" do
      2.times do |n|
        FactoryGirl.create(:nag, user: @user)
      end

      nag = FactoryGirl.create(:nag, user: @user)

      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::NAG_DONE_MESSAGE)

      params = {From: @user.full_phone_number, Body: "Done"}
      Message.route_incoming(params)

      nag.reload

      expect(nag.status).to eq("done")
    end

    it "should send the stop confirm message and stop all nags if the user sends 'stop nags' and the user's current status is active" do
      @user.update_attributes(status: "active")

      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::STOP_CONFIRM_MESSAGE)
      params = {From: @user.full_phone_number, Body: "Stop nags"}
      Message.route_incoming(params)

      @user.reload

      expect(@user.status).to eq("stopped")
    end

    it "should send the already stopped message if the user sends 'stop nags' while his/her status is stopped" do
      @user.update_attributes(status: "stopped")

      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::ALREADY_STOPPED_MESSAGE)
      params = {From: @user.full_phone_number, Body: "Stop nags"}
      Message.route_incoming(params)
    end

    it "should send the restart confirm message and restart all nags if the user sends 'restart nags' and the user's current status is stopped" do
      @user.update_attributes(status: "stopped")

      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::RESTART_CONFIRM_MESSAGE)
      params = {From: @user.full_phone_number, Body: "Restart nags"}
      Message.route_incoming(params)
      
      @user.reload

      expect(@user.status).to eq("active")
    end

    it "should send the already active message if the user sends 'restart nags' and the user's current status is active" do
      @user.update_attributes(status: "active")

      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::ALREADY_ACTIVE_MESSAGE)
      params = {From: @user.full_phone_number, Body: "Restart nags"}
      Message.route_incoming(params)
    end

    it "should send the command list if the user sends 'command list'" do
      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::COMMAND_LIST)
      params = {From: @user.full_phone_number, Body: "Command list"}
      Message.route_incoming(params)
    end

    it "should send the create nag confirmation and create a new nag if the user sends 'remind me to <text>'" do
      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::CREATE_NAG_CONFIRMATION)
      params = {From: @user.full_phone_number, Body: "Remind me to take out the trash"}
      Message.route_incoming(params)

      expect(@user.nags.pluck(:contents)).to include("Take out the trash")
    end

    it "should send the unknown command message if the message is an unknown command and the user is in an active state" do
      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::UNKNOWN_COMMAND_MESSAGE)
      params = {From: @user.full_phone_number, Body: "unknown command"}
      Message.route_incoming(params)
    end
  end

  describe "#send_welcome_message" do
    it "should send welcome message" do
      @user = FactoryGirl.create(:user)
      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::WELCOME_MESSAGE)
      Message.send_welcome_message(@user)
    end
  end

  describe "#send_nag" do
    it "should send a message with the nag's owner's phone number and the nag's contents and update the last_ping_time attribute" do
      user = FactoryGirl.create(:user)
      nag = FactoryGirl.create(:nag, user: user)
      nag_message = "Remember to #{nag.contents}."

      expect(Message).to receive(:send_message).with(nag.user.full_phone_number, nag_message)

      Message.send_nag(nag)
      expect(nag.last_ping_time.inspect).to eq(Time.now.in_time_zone('UTC').inspect)
    end
  end

end
