require 'spec_helper'

FactoryGirl.define do
  factory :user do
    first_name "Joe"
    last_name "Schmoe"
    sequence :phone_number do |n|
      "#{1000000000 + n}"
    end
    password "password"
  end
end
