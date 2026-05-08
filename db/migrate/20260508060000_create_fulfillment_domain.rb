class CreateFulfillmentDomain < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :sku, null: false
      t.string :name, null: false
      t.integer :price_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_check_constraint :products, "price_cents >= 0", name: "products_price_cents_non_negative"

    create_table :orders do |t|
      t.string :number, null: false
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.string :status, null: false, default: "pending_review"
      t.text :shipping_address, null: false
      t.datetime :submitted_at, null: false

      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_index :orders, :status

    create_table :order_line_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false

      t.timestamps
    end
    add_check_constraint :order_line_items, "quantity > 0", name: "order_line_items_quantity_positive"
    add_check_constraint :order_line_items, "unit_price_cents >= 0", name: "order_line_items_unit_price_cents_non_negative"

    create_table :audit_entries do |t|
      t.references :auditable, null: false, polymorphic: true
      t.references :actor, polymorphic: true
      t.string :action, null: false
      t.string :changed_attribute
      t.string :from_value
      t.string :to_value
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end
    add_index :audit_entries, :action
    add_index :audit_entries, :occurred_at
  end
end
