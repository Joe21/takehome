class AddUniqueIndexToCustomFieldsKey < ActiveRecord::Migration[7.2]
  # Ensure idempotent migration for friendly rollbacks on other developers locals
  def change
    remove_index :custom_fields, column: [:client_id, :key] if index_exists?(:custom_fields, [:client_id, :key])
    add_index :custom_fields, [:client_id, :key], unique: true
  end
end
