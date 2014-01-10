require 'spec_helper'

FactoryGirl.define do
  factory :user do
    first_name "Joe"
    last_name "Schmoe"
    phone_number "1234567890"
    password "password"
  end
end
