class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.references :source, index: true, null: false
      t.references :target, index: true, null: false
      t.decimal :amount, null: false
      t.date :date, null: false
      t.date :retracted_on

      t.timestamps null: false
    end

    add_foreign_key :transfers, :accounts, column: :source_id
    add_foreign_key :transfers, :accounts, column: :target_id
  end
end
