require 'rails_helper'

RSpec.describe Customer, type: :model do
  it 'is valid' do
    expect(build(:customer)).to be_valid
  end

  it 'requires a name' do
    expect(build(:customer, name: nil)).to_not be_valid
  end
end
