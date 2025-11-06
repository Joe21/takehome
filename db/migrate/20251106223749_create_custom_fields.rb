class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.jsonb :schema_store, null: false, default: {}
      t.timestamps
    end
  end
end
