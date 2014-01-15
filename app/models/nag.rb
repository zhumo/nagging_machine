class Nag < ActiveRecord::Base
  SID = ENV['TWILIO_ACCOUNT_SID']
  AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
  TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

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
    def route_incoming(params)
      if params[:Body].downcase == "command list"
        Nag.send_command_list(params[:From])
      else
        Nag.send_unknown_command_reply
      end
    end

    def send_message(recipient_phone,body)
      client = Twilio::REST::Client.new(SID,AUTH_TOKEN)

      client.account.messages.create(
        from: TWLIO_PHONE_NUMBER,
        to: recipient_phone,
        body: body
      )
    end

    def send_command_list(recipient_phone)
      command_list = '"Stop" to stop all nags. "Restart" to restart nags, if stopped. "Done" to declare the last nag that was sent to you as done. "Remind me to <text>" to create new nag.'
      send_message(recipient_phone,command_list)
    end
  end
end
