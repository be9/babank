class Account < ActiveRecord::Base
  belongs_to :customer

  validates :customer, presence: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: { scope: :customer_id }, presence: true

  def closed?
    closed_on.present?
  end
end
