FactoryGirl.define do
  factory :account do
    customer
    name { FFaker::Product.brand }   # Trisync, Bruphfunc, Phyckforge, ...
    deposit { BigDecimal.new(rand(1000)) / 100 }  # 0 .. 9.99
    closed_on nil
  end
end
