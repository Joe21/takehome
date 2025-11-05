class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.string :key, null: false
      t.string :label, null: false
      t.string :field_type, null: false
      t.string :enum_options, array: true, default: []
      t.boolean :required, default: false, null: false
      t.timestamps
    end

    add_index :custom_fields, [:client_id, :key], unique: true
  end
end
