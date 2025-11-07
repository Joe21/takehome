class Building < ApplicationRecord
  include UsStates

  belongs_to :client, optional: true

  enum :state, UsStates::STATES

  validates :address, presence: true, uniqueness: { scope: :client_id, case_sensitive: false }
  validates :state, presence: true
  # Validates ZIP to also allow 4-digit extension (12345-6789)
  validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }
  validate :validate_custom_field_values

  private

  # Example custom_field_values
  # {
  #   "num_bathrooms"   => 2,
  #   "exterior_material" => "Wood",
  #   "walkway_type"    => "concrete",
  #   "heating_type"    => "gas"
  # }
  def validate_custom_field_values
    return unless client && custom_field_values.is_a?(Hash)

    client.custom_fields.each do |cf|
      cf.schema_store.each do |key, expected_type|
        value = custom_field_values[key]

        # Validate strings or numbers
        if CustomField::VALID_TYPES.include?(expected_type)
          unless value.is_a?(expected_type == "number" ? Numeric : String)
            errors.add(:custom_field_values, "Invalid value for #{key}: expected #{expected_type}")
          end
        # Validate enum values
        elsif expected_type.is_a?(Array)
          if expected_type.empty? || !expected_type.map(&:downcase).include?(value.to_s.downcase)
            errors.add(:custom_field_values, "Invalid enum value for #{key}")
          end
        # Unknown type in schema_store
        else
          errors.add(:custom_field_values, "Unknown type for #{key}")
        end
      end
    end
  end
end
