class Transfer < ActiveRecord::Base
  belongs_to :source, class_name: 'Account'
  belongs_to :target, class_name: 'Account'

  validates :amount, numericality: { greater_than: 0 }

  validate :check_than_accounts_are_different
  validate :check_that_accounts_are_active

  scope :related, -> account { where('transfers.source_id=:acc_id OR transfers.target_id=:acc_id',
                                     acc_id: account.id) }

  scope :period, -> sd, ed { where('transfers.date BETWEEN ? AND ?', sd, ed) }

  scope :natural_order, -> { order(:date, :id) }

  private

  def check_than_accounts_are_different
    if source && target && source.id == target.id
      errors.add :base, 'source and target cannot be the same!'
    end
  end

  def check_that_accounts_are_active
    if date
      if source.try(:closed_on) && date > source.closed_on
        errors.add :source, "is a closed account"
      end

      if target.try(:closed_on) && date > target.closed_on
        errors.add :target, "is a closed account"
      end
    end
  end
end
