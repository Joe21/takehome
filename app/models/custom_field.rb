class CustomField < ApplicationRecord
  belongs_to :building
  belongs_to :client

  validates :field_store, presence: true
  validate :field_store_must_be_hash
  validate :validate_field_types

  # Update stores using this method. Avoid overloading AR and raise a loud error
  # {
  #   "number::num_bathrooms" => 2,
  #   "string::exterior_material" => "Brick",
  #   "enum::walkway_type" => "Concrete",
  #   "number::floor_count" => 5
  # }

  def update_field_store(new_fields)
    self.field_store = field_store.merge(new_fields)
    save!
  end

  private

  def field_store_must_be_hash
    errors.add(:field_store, "must be a hash") unless field_store.is_a?(Hash)
  end

  def validate_field_types
    field_store.each do |key, value|
      # Use :: to delimit type in key to avoid nested objects
      type, label = key.split("::", 2)

      unless type && label
        errors.add(:field_store, "Invalid key format: #{key}")
        next
      end

      case type
      when "number"
        errors.add(:field_store, "Invalid number for #{key}") unless value.is_a?(Numeric)
      when "string"
        errors.add(:field_store, "Invalid string for #{key}") unless value.is_a?(String)
      when "enum"
        allowed = allowed_enum_values(key)
        errors.add(:field_store, "Invalid enum for #{key}") unless allowed.include?(value)
      else
        errors.add(:field_store, "Unknown type prefix in #{key}")
      end
    end
  end

  # Placeholder: enum options can be defined per key
  def allowed_enum_values(key)
    {
      "enum::walkway_type" => ["Brick", "Concrete", "None"]
    }[key] || []
  end
end
