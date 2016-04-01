class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :customer, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.decimal :deposit, null: false, default: 0
      t.date :closed_on

      t.timestamps null: false
    end
  end
end
