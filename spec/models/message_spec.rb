require 'spec_helper'

describe Message do
  it "should send the unknown_user_message if the user's phone number is not registered. This should also change the user's status to active"

  it "should send the phone confirmation message if the message is a 4-digit number and the message matches the account's confirmation token."

  it "should send the incorrect confirmation code message if the message is a 4-digit number and the message does not match the account's confirmation token. This should reset the confirmation code"

  it "should send the unconfirmed phone number message if the user's account is awaiting confirmation and the user sends a message"

  it "should send the nag done message and declare the user's last nag to be done if the user sends 'done'"

  it "should send the stop confirm message and stop all nags if the user sends 'stop nags' and the user's current status is active"

  it "should send the already stopped message if the user sends 'stop nags' while his/her status is stopped"

  it "should send the restart confirm message and restart all nags if the user sends 'restart nags' and the user's current status is stopped"

  it "should send the already active message if the user sends 'restart nags' and the user's current status is active"

  it "should send the command list if the user sends 'command list'"

  it "should send the create nag confirmation and create a new nag if the user sends 'remind me to <text>'"

  it "should send the unknown command message if the message is an unknown command and the user is in an active state"
end
