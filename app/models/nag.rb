class Nag < ActiveRecord::Base
  validates_presence_of :contents
  validates_presence_of :user_id
  validates_presence_of :status

  belongs_to :user, inverse_of: :nags

  def declare_done
    update_attributes(status: "done")
  end

  def display_status
    user.status == "stopped" ? "stopped" : status
  end
  
  class << self
    SID = ENV['TWILIO_ACCOUNT_SID']
    AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
    TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

    def route_incoming(params)
      message_body = params[:Body]
      message_sender = params[:From]

      if message_body.downcase == "command list"
        Nag.send_command_list(message_sender)
      elsif message_body.downcase.start_with?("remind me to")
        Nag.create_nag(message_sender, message_body)
      else
        Nag.send_unknown_command_reply(message_sender)
      end
    end

    def create_nag(user_phone_number, nag_contents)
      formatted_contents = nag_contents.downcase.sub("remind me to ","").capitalize
      formatted_phone_number = user_phone_number.sub("+1","")
      created_nag = Nag.create(contents: formatted_contents, user_id: User.find_by(phone_number: formatted_phone_number).id)
      Nag.send_message(user_phone_number,"OK. I will remind you")
    end

    def send_message(recipient_phone,body)
      client = Twilio::REST::Client.new(SID, AUTH_TOKEN)

      client.account.messages.create(
        from: TWILIO_PHONE_NUMBER,
        to: recipient_phone,
        body: body
      )
    end

    def send_command_list(recipient_phone)
      command_list = '"Stop" to stop all nags. "Restart" to restart nags, if stopped. "Done" to declare the last nag that was sent to you as done. "Remind me to <text>" to create new nag.'
      Nag.send_message(recipient_phone,command_list)
    end

    def send_unknown_command_reply(recipient_phone)
      unknown_command_reply = "Command not recognized. Respond with \"Command list\" for a list of recognized commands"
      Nag.send_message(recipient_phone,unknown_command_reply)
    end
  end
end
