class CreateCustomValues < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_values do |t|
      t.references :building, null: false, foreign_key: true, index: { unique: true }
      t.jsonb :values, default: {}, null: false  # stores { key: value } pairs
      t.timestamps
    end
  end
end
