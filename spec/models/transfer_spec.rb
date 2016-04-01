require 'rails_helper'

RSpec.describe Transfer, type: :model do
  let(:closed_account) { create(:account, closed_on: Date.new(2016, 4, 1)) }
  let(:open_account) { create(:account) }

  it 'is valid' do
    expect(build(:transfer)).to be_valid
  end

  it 'requires amount to present and be positive' do
    expect(build(:transfer, amount: nil)).to_not be_valid
    expect(build(:transfer, amount: 0)).to_not be_valid
    expect(build(:transfer, amount: -0.01)).to_not be_valid
  end

  it 'requires source and target to be different' do
    expect(build(:transfer, source: open_account, target: open_account)).to_not be_valid
  end

  context 'with a closed source account' do

    it 'is valid with date earlier than close date' do
      expect(build(:transfer, source: closed_account, target: open_account, date: Date.new(2016, 3, 31))).to be_valid
    end

    it 'is valid with date equal to close date' do
      expect(build(:transfer, source: closed_account, target: open_account, date: Date.new(2016, 4, 1))).to be_valid
    end

    it 'is not valid with date greater than close date' do
      expect(build(:transfer, source: closed_account, target: open_account, date: Date.new(2016, 4, 2))).to_not be_valid
    end
  end

  context 'with a closed target account' do

    it 'is valid with date earlier than close date' do
      expect(build(:transfer, target: closed_account, source: open_account, date: Date.new(2016, 3, 31))).to be_valid
    end

    it 'is valid with date equal to close date' do
      expect(build(:transfer, target: closed_account, source: open_account, date: Date.new(2016, 4, 1))).to be_valid
    end

    it 'is not valid with date greater than close date' do
      expect(build(:transfer, target: closed_account, source: open_account, date: Date.new(2016, 4, 2))).to_not be_valid
    end
  end

end
