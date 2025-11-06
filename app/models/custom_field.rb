class CustomField < ApplicationRecord
  belongs_to :building
  belongs_to :client

  validate :field_store_must_be_hash
  # validate :validate_field_types

  # {
  #   "number::num_bathrooms" => 2.5,
  #   "string::exterior_material" => "Brick",
  #   "enum::walkway_type" => "concrete",
  # }

  # Update stores using this method. Avoid overloading AR and raise a loud error
  def update_field_store(new_fields)
    self.field_store = field_store.merge(new_fields)
    save!
  end

  # Make this public for now
  def allowed_enum_values(key)
    enum_key = key.split("::", 2).last.to_sym
    self.class.enum_config[enum_key] || []
  end

  private

  def field_store_must_be_hash
    return errors.add(:field_store, "must be a hash") if field_store.nil?
    
    errors.add(:field_store, "must be a hash") unless field_store.is_a?(Hash)
  end

  def validate_field_types
    return unless field_store.is_a?(Hash)

    field_store.each do |key, value|
      # Use :: to delimit type in key to avoid nested objects
      type, label = key.split("::", 2)

      unless type.present? && label.present?
        errors.add(:field_store, "Invalid key format: #{key}")
        next
      end

      case type
      when "number"
        errors.add(:field_store, "Invalid number for #{key}") unless value.is_a?(Numeric)
      when "string"
        errors.add(:field_store, "Invalid string for #{key}") unless value.is_a?(String)
      when "enum"
        allowed = allowed_enum_values(key).map(&:downcase)
        errors.add(:field_store, "Invalid enum for #{key}") unless allowed.include?(value.to_s.downcase)
      else
        errors.add(:field_store, "Unknown type prefix in #{key}")
      end
    end
  end

  def enum_config
    self.class.enum_config
  end

  def self.enum_config
    @enum_config ||= YAML.load_file(Rails.root.join('app/models/custom_field_enums.yml')).deep_symbolize_keys
  end
end
