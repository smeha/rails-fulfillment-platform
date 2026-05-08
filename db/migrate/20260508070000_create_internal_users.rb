class CreateInternalUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :internal_users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_sign_in_at

      t.timestamps
    end

    add_index :internal_users, "LOWER(email)", unique: true, name: "index_internal_users_on_lower_email"
    add_index :internal_users, :active
  end
end
