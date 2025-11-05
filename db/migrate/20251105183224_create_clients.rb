class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :clients, 'LOWER(name)', unique: true, name: 'index_clients_on_lower_name'
  end
end
