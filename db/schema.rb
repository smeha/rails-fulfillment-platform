# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_08_070000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_entries", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.string "actor_type"
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.string "changed_attribute"
    t.datetime "created_at", null: false
    t.string "from_value"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.string "to_value"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_entries_on_action"
    t.index ["actor_type", "actor_id"], name: "index_audit_entries_on_actor"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_entries_on_auditable"
    t.index ["occurred_at"], name: "index_audit_entries_on_occurred_at"
  end

  create_table "internal_users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "last_sign_in_at"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_internal_users_on_lower_email", unique: true
    t.index ["active"], name: "index_internal_users_on_active"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["product_id"], name: "index_order_line_items_on_product_id"
    t.check_constraint "quantity > 0", name: "order_line_items_quantity_positive"
    t.check_constraint "unit_price_cents >= 0", name: "order_line_items_unit_price_cents_non_negative"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email", null: false
    t.string "customer_name", null: false
    t.string "number", null: false
    t.text "shipping_address", null: false
    t.string "status", default: "pending_review", null: false
    t.datetime "submitted_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.string "sku", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.check_constraint "price_cents >= 0", name: "products_price_cents_non_negative"
  end

  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "products"
end
