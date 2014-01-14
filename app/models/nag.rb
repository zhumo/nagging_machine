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

  def self.route_incoming(params)
    self.send_unknown_command_error(params[:From])
  end

  def self.send_unknown_command_error(recipient_phone)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'],ENV['TWILIO_AUTH_TOKEN'])

    client.account.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: recipient_phone,
      body: "Sorry, that is not a recognized command."
    )
  end
end
