class Message < ActiveRecord::Base
    SID = ENV['TWILIO_ACCOUNT_SID']
    AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
    TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

    #Text of all the stock message
    COMMAND_LIST = '"Stop nags" to stop all nags. "Restart nags" to restart nags, if stopped. "Done" to declare the last nag that was sent to you as done. "Remind me to <text>" to create new nag.'
    UNKNOWN_COMMAND_MESSAGE = "Command not recognized. Respond with \"Command list\" for a list of recognized commands"
    UNKNOWN_USER_MESSAGE = "Sorry, I don't recognize your number. Sign up for The Nagging Machine at www.thenaggingmachine.com"
    STOP_CONFIRM_MESSAGE = "All nags stopped. Respond with \"Restart nags\" to restart the nagging."
    ALREADY_STOPPED_MESSAGE = "Your nags are already stopped. Respond with \"Restart nags\" to restart the nagging."
    RESTART_CONFIRM_MESSAGE = "Your nags have been restarted. Welcome back!"
    ALREADY_ACTIVE_MESSAGE = "Your nags are already active. Respond with \"Stop nags\" to stop all nags."
    NAG_DONE_MESSAGE = "Good job! I'll stop nagging you about it now."
    PHONE_CONFIRMATION_MESSAGE = "Your phone number has been confirmed. Respond with \"Command list\" to see a list of all text commands you can use."
    INCORRECT_CONFIRMATION_CODE_MESSAGE = "That code is not recognized. Please refresh the page for a new code and try again. This may have happended because confirmation codes become invalid after one hour." 
    WELCOME_MESSAGE = "Welcome to the Nagging Machine! Please enter the 4-digit code you see on your screen."
    UNCONFIRMED_PHONE_NUMBER_MESSAGE = "Your phone number is unconfirmed. Please visit www.thenaggingmachine.com, log in, and send the 4-digit code found on the screen."
    CREATE_NAG_CONFIRMATION = "OK. I will nag you until you do it!"
  class << self

    def route_incoming(params)
      message_body = params[:Body]
      message_sender = params[:From]
      user = User.find_by(phone_number: message_sender.sub("+1",""))

      if !User.pluck(:phone_number).include?(message_sender.sub("+1",""))
        reply_body = UNKNOWN_USER_MESSAGE
      elsif message_body.match(/\A\d{4}\z/) && user.awaiting_confirmation?
        if user.confirmation_code == message_body && user.confirmation_code_time + 1.hour > Time.now
          user.confirm_phone_number
          reply_body = PHONE_CONFIRMATION_MESSAGE
        else
          user.generate_confirmation_code
          reply_body = INCORRECT_CONFIRMATION_CODE_MESSAGE
        end
      elsif user.awaiting_confirmation?
        reply_body = UNCONFIRMED_PHONE_NUMBER_MESSAGE
      elsif message_body.downcase == "done"
        user.last_ping.declare_done
        reply_body = NAG_DONE_MESSAGE
      elsif message_body.downcase == "stop nags"
        if user.active?
          user.stop_all_nags
          reply_body = STOP_CONFIRM_MESSAGE
        else
          reply_body = ALREADY_STOPPED_MESSAGE
        end
      elsif message_body.downcase == "restart nags"
        if user.stopped?
          user.restart_all_nags
          reply_body = RESTART_CONFIRM_MESSAGE
        else
          reply_body = ALREADY_ACTIVE_MESSAGE
        end
      elsif message_body.downcase == "command list"
        reply_body = COMMAND_LIST
      elsif message_body.downcase.start_with?("remind me to")
        Message.create_nag(user, message_body)
        reply_body = CREATE_NAG_CONFIRMATION
      else
        reply_body = UNKNOWN_COMMAND_MESSAGE
      end

      Message.send_message(message_sender,reply_body)
    end

    def send_welcome_message(user)
      Message.send_message(user.full_phone_number, Message::WELCOME_MESSAGE)
    end

    def send_nag(nag)
      nag_message = "Remember to #{nag.contents}."
      Message.send_message(nag.user.full_phone_number, nag_message)
      nag.update_attribute(:last_ping_time, Time.now)
      nag.generate_next_ping_time
      nag.update_attribute(:ping_count, ping_count += 1)
      Sidekiq::Queue.new.clear
      Nag.populate_sidekiq
    end

    protected

    def send_message(recipient_phone,body)
      client = Twilio::REST::Client.new(SID, AUTH_TOKEN)

      client.account.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: recipient_phone,
        body: body
      )
    end

    def create_nag(user, nag_contents)
      formatted_contents = nag_contents.downcase.sub("remind me to ","").capitalize

      Nag.create(contents: formatted_contents, user_id: user.id)
    end
  end
end
