FactoryGirl.define do
  factory :nag do
    sequence :contents do |n|
      "nag#{n}"
    end

    sequence :last_ping_time do |n|
      Time.now - n.minute
    end

    sequence :next_ping_time do |n|
      Time.now + n.minute
    end

    user
  end
end
