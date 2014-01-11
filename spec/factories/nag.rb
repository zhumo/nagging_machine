FactoryGirl.define do
  factory :nag do
    sequence :contents do |n|
      "nag#{n}"
    end
  end
end
