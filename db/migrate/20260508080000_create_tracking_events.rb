class CreateTrackingEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :tracking_events do |t|
      t.references :order, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :carrier, null: false
      t.string :tracking_number, null: false
      t.string :status, null: false
      t.string :description, null: false
      t.datetime :occurred_at, null: false
      t.jsonb :raw_payload, null: false, default: {}

      t.timestamps
    end

    add_index :tracking_events, [ :order_id, :external_id ], unique: true
    add_index :tracking_events, [ :order_id, :occurred_at ]
  end
end
