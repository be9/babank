FactoryGirl.define do
  factory :customer do
    name { FFaker::Name.name }
  end
end
