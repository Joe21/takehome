class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.jsonb :field_store, null: false, default: {}
      t.timestamps
    end

    add_index :custom_fields, [:building_id, :client_id], unique: true
    add_index :custom_fields, :field_store, using: :gin
  end
end