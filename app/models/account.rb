class Account < ActiveRecord::Base
  belongs_to :customer

  validates :customer, presence: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: { scope: :customer_id }, presence: true

  def closed?
    closed_on.present?
  end

  def balance(for_date = nil)
    tr = Transfer.arel_table

    sum_function = Arel::Nodes::NamedFunction.new('SUM', [tr[:amount]])
    aggregation = Arel::Nodes::NamedFunction.new('COALESCE', [sum_function, 0], 'total_amount')

    base = tr.project(aggregation).where(tr[:retracted_on].eq(nil))
    base = base.where(tr[:date].lteq(for_date)) if for_date

    incoming = base.dup.where(tr[:target_id].eq(self.id))
    outgoing = base.where(tr[:source_id].eq(self.id))

    res = self.class.connection.select_one "SELECT ((#{incoming.to_sql}) - (#{outgoing.to_sql})) AS balance"

    deposit + BigDecimal.new(res["balance"] || 0)
  end
end
