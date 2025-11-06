class CustomField < ApplicationRecord
  belongs_to :client

  VALID_TYPES = %w[number string].freeze

  validate :schema_store_must_be_hash
  validate :validate_schema_store

  # Example schema_store :
  # {
  #   "num_bathrooms" => "number",
  #   "exterior_material" => "string",
  #   "walkway_type" => ["brick", "concrete", "none", "unknown"]
  # }

  private

  def schema_store_must_be_hash
    return errors.add(:schema_store, "must be a hash") if schema_store.nil?

    errors.add(:schema_store, "must be a hash") unless schema_store.is_a?(Hash)
  end

  def validate_schema_store
    return unless schema_store.is_a?(Hash)

    schema_store.each do |key, value|
      if key.blank?
        errors.add(:schema_store, "Key cannot be blank")
        next
      end

      case value
      # valid types
      when *VALID_TYPES
        next
      # valid array of strings
      when Array
        if value.empty? || !value.all? { |v| v.is_a?(String) }
          errors.add(:schema_store, "Enum array must contain at least one string for #{key}")
        end
      # unrecognized
      else
        errors.add(:schema_store, "Invalid type/value for #{key}")
      end
    end
  end
end
