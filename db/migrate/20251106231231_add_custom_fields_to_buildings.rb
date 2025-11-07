class AddCustomFieldsToBuildings < ActiveRecord::Migration[7.2]
  def change
    add_column :buildings, :custom_field_values, :jsonb, default: {}, null: false
    add_index :buildings, :custom_field_values, using: :gin
  end
end
