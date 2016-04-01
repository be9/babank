class Customer < ActiveRecord::Base
  validates :name, presence: true

  has_many :accounts
end
