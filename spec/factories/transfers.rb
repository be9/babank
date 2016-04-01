FactoryGirl.define do
  factory :transfer do
    association :source, factory: :account
    association :target, factory: :account
    amount { BigDecimal.new(1+rand(1000)) / 100 }  # 0 .. 9.99
    date { Date.today }
    retracted_on nil
  end
end
