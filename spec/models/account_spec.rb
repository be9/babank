require 'rails_helper'

RSpec.describe Account, type: :model do
  it 'is valid' do
    expect(build(:account)).to be_valid
  end

  it 'requires a name' do
    expect(build(:account, name: nil)).to_not be_valid
  end

  it 'requires a valid deposit' do
    expect(build(:account, deposit: -1)).to_not be_valid
  end

  it 'requires a unique name' do
    acc = create(:account)

    expect(build(:account, customer: acc.customer, name: acc.name)).to_not be_valid
  end

  context '#closed?' do
    it 'is true for a closed account' do
      expect(build(:account, closed_on: Date.today)).to be_closed
    end

    it 'is false for a non-closed account' do
      expect(build(:account, closed_on: nil)).to_not be_closed
    end
  end

  context '#balance' do
    it 'is 0 for empty, just created account' do
      expect(create(:account, deposit: 0).balance).to be_zero
    end

    it 'equals to deposit for account without transfers' do
      expect(create(:account, deposit: 5.17).balance).to eq(BigDecimal.new("5.17"))
    end

    it 'considers transfers' do
      acc1 = create(:account, deposit: 100)
      acc2 = create(:account, deposit: 200)

      tr = create(:transfer, source: acc2, target: acc1, amount: 20)

      expect(acc1.balance).to eq(120)
      expect(acc2.balance).to eq(180)
    end

    it 'skips retracted transfers' do
      acc1 = create(:account, deposit: 100)
      acc2 = create(:account, deposit: 200)

      tr = create(:transfer, source: acc2, target: acc1, amount: 20, retracted_on: Date.today)

      expect(acc1.balance).to eq(100)
      expect(acc2.balance).to eq(200)
    end

    it 'considers for_date argument' do
      acc1 = create(:account, deposit: 100)
      acc2 = create(:account, deposit: 200)

      create(:transfer, source: acc2, target: acc1, amount: 20, date: Date.new(2014, 4, 1))
      create(:transfer, source: acc2, target: acc1, amount: 50, date: Date.new(2014, 4, 2))

      expect(acc1.balance(Date.new(2014, 4, 1))).to eq(120)
      expect(acc2.balance(Date.new(2014, 4, 1))).to eq(180)
    end
  end
end
