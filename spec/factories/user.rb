require 'spec_helper'

FactoryGirl.define do
  factory :user do
    first_name "Joe"
    last_name "Schmoe"
    status "active"
    sequence :phone_number do |n|
      "#{1000000000 + n}"
    end
    password "password"

    trait :unconfirmed do
      status "awaiting confirmation"
      confirmation_code "1234"
      confirmation_code_time Time.now
    end

    factory :unconfirmed_user, traits: [:unconfirmed]
  end
end
