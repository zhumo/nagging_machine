require 'spec_helper'

describe Message do
  describe ".route_incoming" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @unconfirmed_user = FactoryGirl.create(:unconfirmed_user)
    end

    context "WHEN the incoming message's phone number does not match the phone number of an existing user" do
      it "IT should send the unknown_user_message if the user's phone number is not registered" do
        expect(Message).to receive(:send_message).with("+10987654321", Message::UNKNOWN_USER_MESSAGE)
        params = {From: "+10987654321", Body: "test"}
        Message.route_incoming(params)
      end
    end

    context "WHEN the incoming message's phone number matches the phone number of an existing user" do
      context "AND the user is awaiting confirmation" do
        context "AND the message body consists only of four digits" do
          context "AND the user's confirmation_code attribute matches the message body AND the confirmation_code_time was less than 1 hour ago" do
            it "IT should send the phone confirmation message" do
              expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::PHONE_CONFIRMATION_MESSAGE)
              params = {From: @unconfirmed_user.full_phone_number, Body: @unconfirmed_user.confirmation_code}
              Message.route_incoming(params)

              @unconfirmed_user.reload

              expect(@unconfirmed_user.confirmation_code).to be_nil
              expect(@unconfirmed_user.confirmation_code_time).to be_nil
            end
          end

          context "AND the user's confirmation_code attributes does not match the message body OR the confirmation_code_time was greater than 1 hour ago" do
            it "IT should send the incorrect confirmation code message and reset the confirmation code" do
              time = @unconfirmed_user.confirmation_code_time

              expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::INCORRECT_CONFIRMATION_CODE_MESSAGE)
              params = {From: @unconfirmed_user.full_phone_number, Body: "4321"}
              Message.route_incoming(params)

              @unconfirmed_user.reload

              expect(@unconfirmed_user.confirmation_code).to_not eq("1234")
              expect(@unconfirmed_user.confirmation_code_time).to_not eq(time)
            end
          end
        end

        context "AND the message body does not consist of only four digits" do
          it "IT should send the unconfirmed phone number message if the user's account is awaiting confirmation and the user sends a message" do
            expect(Message).to receive(:send_message).with(@unconfirmed_user.full_phone_number, Message::UNCONFIRMED_PHONE_NUMBER_MESSAGE)
            params = {From: @unconfirmed_user.full_phone_number, Body: "test"}
            Message.route_incoming(params)
          end
        end
      end

      context "AND the user is not awaiting confirmation" do
        context "AND the message body is 'done'" do
          it "IT should send the nag done message and declare the user's last nag to be done" do
            2.times do |n|
              FactoryGirl.create(:nag, user: @user)
            end

            nag = FactoryGirl.create(:nag, user: @user, last_ping_time: Time.now + 1.hour)

            expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::NAG_DONE_MESSAGE)

            params = {From: @user.full_phone_number, Body: "Done"}
            Message.route_incoming(params)

            nag.reload

            expect(nag.status).to eq("done")
          end
        end

        context "AND the message body is 'stop nags'" do
          context "AND the user's status is 'active'" do
            it "IT should send the stop confirm message and stop all nags" do
              @user.update_attributes(status: "active")

              expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::STOP_CONFIRM_MESSAGE)
              params = {From: @user.full_phone_number, Body: "Stop nags"}
              Message.route_incoming(params)

              @user.reload

              expect(@user.status).to eq("stopped")
            end
          end

          context "AND the user's status is not 'active'" do
            it "IT should send the already stopped message" do
              @user.update_attributes(status: "stopped")

              expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::ALREADY_STOPPED_MESSAGE)
              params = {From: @user.full_phone_number, Body: "Stop nags"}
              Message.route_incoming(params)
            end
          end
        end

        context "AND the message body is 'restart nags'" do
          context "AND the user's status is 'stopped'" do
            it "IT should send the restart confirm message and restart all nags" do
              @user.update_attributes(status: "stopped")

              expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::RESTART_CONFIRM_MESSAGE)
              params = {From: @user.full_phone_number, Body: "Restart nags"}
              Message.route_incoming(params)
              
              @user.reload

              expect(@user.status).to eq("active")
            end
          end

          context "AND the user's status is not 'stopped'" do
            it "IT should send the already active message" do
              @user.update_attributes(status: "active")

              expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::ALREADY_ACTIVE_MESSAGE)
              params = {From: @user.full_phone_number, Body: "Restart nags"}
              Message.route_incoming(params)
            end
          end
        end

        context "AND the message body is 'command list'" do
          it "IT should send the command list if the user sends 'command list'" do
            expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::COMMAND_LIST)
            params = {From: @user.full_phone_number, Body: "Command list"}
            Message.route_incoming(params)
          end
        end

        context "AND the message body starts with 'remind me to'" do
          it "IT should send the create nag confirmation and create a new nag if the user sends 'remind me to <text>'" do
            expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::CREATE_NAG_CONFIRMATION)
            params = {From: @user.full_phone_number, Body: "Remind me to take out the trash"}
            Message.route_incoming(params)

            expect(@user.nags.pluck(:contents)).to include("Take out the trash")
          end
        end

        context "AND the message body is not a recognized command" do
          it "IT should send the unknown command message if the message is an unknown command and the user is in an active state" do
            expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::UNKNOWN_COMMAND_MESSAGE)
            params = {From: @user.full_phone_number, Body: "unknown command"}
            Message.route_incoming(params)
          end
        end
      end
    end
  end

  describe ".send_welcome_message" do
    it "IT should send welcome message" do
      @user = FactoryGirl.create(:user)
      expect(Message).to receive(:send_message).with(@user.full_phone_number, Message::WELCOME_MESSAGE)
      Message.send_welcome_message(@user)
    end
  end

  describe ".send_nag" do
    it "IT should send a message with the nag's owner's phone number and the nag's contents and update the last_ping_time attribute" do
      user = FactoryGirl.create(:user)
      nag = FactoryGirl.create(:nag, user: user)
      nag_message = "Remember to #{nag.contents}."

      expect(Message).to receive(:send_message).with(nag.user.full_phone_number, nag_message)

      Message.send_nag(nag)
      expect(nag.last_ping_time.inspect).to eq(Time.now.in_time_zone('UTC').inspect)
    end
  end
end
