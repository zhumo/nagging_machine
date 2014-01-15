class Message < ActiveRecord::Base
  class << self
    SID = ENV['TWILIO_ACCOUNT_SID']
    AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
    TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

    #Text of all the stock message
    COMMAND_LIST = '"Stop nags" to stop all nags. "Restart nags" to restart nags, if stopped. "Done" to declare the last nag that was sent to you as done. "Remind me to <text>" to create new nag.'
    UNKNOWN_COMMAND_MESSAGE = "Command not recognized. Respond with \"Command list\" for a list of recognized commands"
    UNKNOWN_USER_MESSAGE = "I don't recognize your number. Sign up for The Nagging Machine at www.thenaggingmachine.com"
    STOP_CONFIRM_MESSAGE = "All nags stopped. Respond with \"Restart nags\" to restart the nagging."
    ALREADY_STOPPED_MESSAGE = "Your nags are already stopped. Respond with \"Restart nags\" to restart the nagging."
    RESTART_CONFIRM_MESSAGE = "Your nags have been restarted. Welcome back!"
    ALREADY_ACTIVE_MESSAGE = "Your nags are already active. Respond with \"Stop nags\" to stop all nags."
    NAG_DONE_MESSAGE = "Good job! I'll stop nagging you about it now."
    PHONE_CONFIRMATION_MESSAGE = "Your phone number has been confirmed. Respond with \"Command list\" to see a list of all text commands you can use."
    INCORRECT_CONFIRMATION_CODE_MESSAGE = "That code is not recognized. Confirmation codes become invalid after one hour. Please refresh the page for a new code and try again."
    WELCOME_MESSAGE = "Welcome to the Nagging Machine! Please enter the 4-digit code you see on your screen."
    UNCONFIRMED_PHONE_NUMBER_MESSAGE = "Your phone number is unconfirmed. Please visit www.thenaggingmachine.com, log in, and send the 4-digit code found on the screen."
    CREATE_NAG_CONFIRMATION = "OK. I will nag you until you do it!"

    def route_incoming(params)
      message_body = params[:Body]
      message_sender = params[:From]
      user = User.find_by(phone_number: message_sender.sub("+1",""))

      #Does user exist in DB?
      if !User.pluck(:phone_number).include?(message_sender.sub("+1",""))
        Message.send_message(message_sender,UNKNOWN_USER_MESSAGE)
      #is the user trying to send in a confirmation code?
      elsif message_body.match(/\A\d{4}\z/) && user.has_confirmation_code?
        if user.confirmation_code == message_body && user.confirmation_code_time + 1.hour > Time.now
          user.confirm_phone_number
          Message.send_message(message_sender,PHONE_CONFIRMATION_MESSAGE)
        else
          Message.send_message(message_sender,INCORRECT_CONFIRMATION_CODE_MESSAGE)
        end
      #A user whose phone number has not been confirmed cannot access the other functionality below
      elsif user.awaiting_confirmation?
        Message.send_message(message_sender,UNCONFIRMED_PHONE_NUMBER_MESSAGE)
      # is the user trying to declare a nag done?
      elsif message_body.downcase == "done"
        user.last_ping.declare_done
        Message.send_message(message_sender, NAG_DONE_MESSAGE)
      #is the user trying to stop all nags?
      elsif message_body.downcase == "stop nags"
        if user.active?
          user.stop_all_nags
          Message.send_message(message_sender,STOP_CONFIRM_MESSAGE)
        else
          Message.send_message(message_sender,ALREADY_STOPPED_MESSAGE)
        end
      #is the user trying to restart nags?
      elsif message_body.downcase == "restart nags"
        if user.stopped?
          user.restart_all_nags
          Message.send_message(message_sender,RESTART_CONFIRM_MESSAGE)
        else
          Message.send_message(message_sender,ALREADY_ACTIVE_MESSAGE)
        end
      #is the user trying to access the command list?
      elsif message_body.downcase == "command list"
        Message.send_message(message_sender,COMMAND_LIST)
      #is the user trying to add a new nag?
      elsif message_body.downcase.start_with?("remind me to")
        Message.create_nag(user, message_body)
        Message.send_message(user_phone_number,CREATE_NAG_CONFIRMATION)
      #if none of the above, then the user must have sent a command not recognized by the app.
      else
        Message.send_message(message_sender,UNKNOWN_COMMAND_MESSAGE)
      end
    end

    private

    def create_nag(user, nag_contents)
      formatted_contents = nag_contents.downcase.sub("remind me to ","").capitalize

      Nag.create(contents: formatted_contents, user_id: user.id)
    end

    def send_message(recipient_phone,body)
      client = Twilio::REST::Client.new(SID, AUTH_TOKEN)

      client.account.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: recipient_phone,
        body: body
      )
    end
  end
end
