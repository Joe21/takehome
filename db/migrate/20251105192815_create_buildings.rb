class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.references :client, null: false, foreign_key: true
      t.string :address, null: false
      t.integer :zip5, null: false, limit: 5
      t.string :state, limit: 2, null: false
      t.timestamps
    end

    add_index :buildings, 'LOWER(address)', unique: true, name: 'index_buildings_on_lower_address'
    add_index :buildings, [:state, :zip5], name: 'index_buildings_on_state_and_zip5'
  end
end
