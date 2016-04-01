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
end
