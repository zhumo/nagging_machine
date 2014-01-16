require 'spec_helper'

describe Message do
  describe "route_incoming" do
    let(:from) {"+12345678901"}

    before(:each) do
      @user = FactoryGirl.create(:user, phone_number: from.sub("+1",""), status: "active")
    end

    it "should send the unknown_user_message if the user's phone number is not registered. This should also change the user's status to active" do
      expect(Message).to receive(:send_message).with("+10987654321", Message::UNKNOWN_USER_MESSAGE)
      params = {From: "+10987654321", Body: "test"}
      Message.route_incoming(params)
    end

    it "should send the phone confirmation message if the message is a 4-digit number and the message matches the account's confirmation token and the message is sent within 1 hour of the confirmation code creation. This should make the confirmation code empty" do
      @user.update_attributes(confirmation_code: "1234", confirmation_code_time: Time.now - 30.minutes)

      expect(Message).to receive(:send_message).with(from, Message::PHONE_CONFIRMATION_MESSAGE)
      params = {From: from, Body: "1234"}
      Message.route_incoming(params)

      @user.reload

      expect(@user.confirmation_code).to be_nil
      expect(@user.confirmation_code_time).to be_nil
    end

    it "should send the incorrect confirmation code message if the message is a 4-digit number and the message does not match the account's confirmation token and the message is sent within 1 hour of the confirmation code's creation. This should reset the confirmation code" do
      @user.update_attributes(confirmation_code: "1234", confirmation_code_time: Time.now - 30.minutes)
      time = @user.confirmation_code_time

      expect(Message).to receive(:send_message).with(from, Message::INCORRECT_CONFIRMATION_CODE_MESSAGE)
      params = {From: from, Body: "4321"}
      Message.route_incoming(params)

      @user.reload

      expect(@user.confirmation_code).to_not eq("1234")
      expect(@user.confirmation_code_time).to_not eq(time)
    end

    it "should send the incorrect confirmation code message if the message is a 4-digit number and the message does match the account's confirmation token and the message is sent more than 1 hour of the confirmation code's creation. This should reset the confirmation code" do
      @user.update_attributes(confirmation_code: "1234", confirmation_code_time: Time.now - 120.minutes)
      time = @user.confirmation_code_time

      expect(Message).to receive(:send_message).with(from, Message::INCORRECT_CONFIRMATION_CODE_MESSAGE)
      params = {From: from, Body: "1234"}
      Message.route_incoming(params)

      @user.reload

      expect(@user.confirmation_code).to_not eq("1234")
      expect(@user.confirmation_code_time).to_not eq(time)
    end

    it "should send the unconfirmed phone number message if the user's account is awaiting confirmation and the user sends a message" do
      @user.update_attributes(confirmation_code: "1234", confirmation_code_time: Time.now)

      expect(Message).to receive(:send_message).with(from, Message::UNCONFIRMED_PHONE_NUMBER_MESSAGE)
      params = {From: from, Body: "test"}
      Message.route_incoming(params)
    end

    it "should send the nag done message and declare the user's last nag to be done if the user sends 'done'" do
      2.times do |n|
        @user.nags.create(contents: "nag_#{n}", last_ping_time: Time.now - (n + 1).hour)
      end

      nag = @user.nags.create(contents: "last nag", last_ping_time: Time.now)

      expect(Message).to receive(:send_message).with(from, Message::NAG_DONE_MESSAGE)

      params = {From: from, Body: "Done"}
      Message.route_incoming(params)

      nag.reload

      expect(nag.status).to eq("done")
    end

    it "should send the stop confirm message and stop all nags if the user sends 'stop nags' and the user's current status is active" do
      @user.update_attributes(status: "active")

      expect(Message).to receive(:send_message).with(from, Message::STOP_CONFIRM_MESSAGE)
      params = {From: from, Body: "Stop nags"}
      Message.route_incoming(params)

      @user.reload

      expect(@user.status).to eq("stopped")
    end

    it "should send the already stopped message if the user sends 'stop nags' while his/her status is stopped" do
      @user.update_attributes(status: "stopped")

      expect(Message).to receive(:send_message).with(from, Message::ALREADY_STOPPED_MESSAGE)
      params = {From: from, Body: "Stop nags"}
      Message.route_incoming(params)
    end

    it "should send the restart confirm message and restart all nags if the user sends 'restart nags' and the user's current status is stopped" do
      @user.update_attributes(status: "stopped")

      expect(Message).to receive(:send_message).with(from, Message::RESTART_CONFIRM_MESSAGE)
      params = {From: from, Body: "Restart nags"}
      Message.route_incoming(params)
      
      @user.reload

      expect(@user.status).to eq("active")
    end

    it "should send the already active message if the user sends 'restart nags' and the user's current status is active" do
      @user.update_attributes(status: "active")

      expect(Message).to receive(:send_message).with(from, Message::ALREADY_ACTIVE_MESSAGE)
      params = {From: from, Body: "Restart nags"}
      Message.route_incoming(params)
    end

    it "should send the command list if the user sends 'command list'" do
      expect(Message).to receive(:send_message).with(from, Message::COMMAND_LIST)
      params = {From: from, Body: "Command list"}
      Message.route_incoming(params)
    end

    it "should send the create nag confirmation and create a new nag if the user sends 'remind me to <text>'" do
      expect(Message).to receive(:send_message).with(from, Message::CREATE_NAG_CONFIRMATION)
      params = {From: from, Body: "Remind me to take out the trash"}
      Message.route_incoming(params)

      expect(@user.nags.pluck(:contents)).to include("Take out the trash")
    end

    it "should send the unknown command message if the message is an unknown command and the user is in an active state" do
      expect(Message).to receive(:send_message).with(from, Message::UNKNOWN_COMMAND_MESSAGE)
      params = {From: from, Body: "unknown command"}
      Message.route_incoming(params)
    end
  end
end
