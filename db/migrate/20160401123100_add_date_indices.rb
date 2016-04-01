class AddDateIndices < ActiveRecord::Migration
  def up

    remove_index "transfers", ["source_id"]
    remove_index "transfers", ["target_id"]

    add_index "transfers", ["source_id", "date"]
    add_index "transfers", ["target_id", "date"]
  end

  def down
    remove_index "transfers", ["source_id", "date"]
    remove_index "transfers", ["target_id", "date"]

    add_index "transfers", ["source_id"]
    add_index "transfers", ["target_id"]
  end
end
