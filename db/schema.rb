# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160401123100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: :cascade do |t|
    t.integer  "customer_id",               null: false
    t.string   "name",                      null: false
    t.decimal  "deposit",     default: 0.0, null: false
    t.date     "closed_on"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "accounts", ["customer_id"], name: "index_accounts_on_customer_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.integer  "source_id",    null: false
    t.integer  "target_id",    null: false
    t.decimal  "amount",       null: false
    t.date     "date",         null: false
    t.date     "retracted_on"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "transfers", ["source_id", "date"], name: "index_transfers_on_source_id_and_date", using: :btree
  add_index "transfers", ["target_id", "date"], name: "index_transfers_on_target_id_and_date", using: :btree

  add_foreign_key "accounts", "customers"
  add_foreign_key "transfers", "accounts", column: "source_id"
  add_foreign_key "transfers", "accounts", column: "target_id"
end
