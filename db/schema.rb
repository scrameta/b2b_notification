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

ActiveRecord::Schema.define(version: 2020_12_06_162009) do

  create_table "clients", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "surname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_clients_on_username"
  end

  create_table "employees", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "surname"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_employees_on_username"
  end

  create_table "market_data", force: :cascade do |t|
    t.date "date"
    t.string "ticker"
    t.float "open"
    t.float "high"
    t.float "low"
    t.float "close"
    t.float "adjusted_close"
    t.integer "volume"
    t.float "dividend_amount"
    t.float "split_coefficient"
  end

  create_table "notification_assignments", force: :cascade do |t|
    t.integer "notification_id"
    t.integer "client_id"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_notification_assignments_on_client_id"
    t.index ["notification_id"], name: "index_notification_assignments_on_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "message"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_notifications_on_employee_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "name"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_portfolios_on_client_id"
  end

  create_table "trades", force: :cascade do |t|
    t.string "ticker"
    t.integer "side"
    t.float "price"
    t.integer "quantity"
    t.date "tradeDate"
    t.integer "portfolio_id"
    t.index ["portfolio_id"], name: "index_trades_on_portfolio_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
