class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.references :client, null: false, foreign_key: true
      t.string :address, null: false
      t.string :zip_code, null: false
      t.string :state, limit: 2, null: false
      t.timestamps
    end

    add_index :buildings, 'LOWER(address)', unique: true, name: 'index_buildings_on_lower_address'
    add_index :buildings, [:state, :zip_code], name: 'index_buildings_on_state_and_zip_code'
  end
end
