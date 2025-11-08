module Buildings
  class Create
    # Catch Unknown Errors
    class Error < StandardError; end

    # Catch Validation Errors
    class ValidationError < StandardError; end

    attr_reader :client, :params
    attr_accessor :building

    def initialize(client, params)
      @client = client
      @params = params.permit(:address, :zip_code, :state, custom_field_values: {})
    end

    def call
      validate_custom_fields!
      self.building = client.buildings.new(params)

      if building.save
        { building: serialize_building }
      else
        # Raise clientside 422
        raise ValidationError, building.errors.full_messages.join(", ")
      end
    # let ValidationError propagate or it will be caught by StandError
    rescue ValidationError
      raise
    # Raise internal 500
    rescue StandardError => e
      raise Error, e.message
    end

    private

    def validate_custom_fields!
      cf_keys = client.custom_fields.flat_map { |cf| cf.schema_store.keys }.uniq
      input_keys = params[:custom_field_values]&.keys || []

      invalid_keys = input_keys - cf_keys
      raise ValidationError, "Invalid custom field keys: #{invalid_keys.join(', ')}" if invalid_keys.any?

      params[:custom_field_values]&.each do |key, value|
        expected_type = client.custom_fields
                              .map(&:schema_store)
                              .find { |store| store[key] }
                              &.[](key)
        next unless expected_type

        case expected_type
        when "number"
          raise ValidationError, "Invalid value for #{key}: expected number" unless value.is_a?(Numeric)
        when "string"
          raise ValidationError, "Invalid value for #{key}: expected string" unless value.is_a?(String)
        when Array
          raise ValidationError, "Invalid value for #{key}: expected one of #{expected_type.join(', ')}" unless expected_type.include?(value)
        end
      end
    end

    def serialize_building
      {
        id: building.id,
        client_name: client.name,
        address: building.address,
        zip_code: building.zip_code,
        state: building.state,
        custom_field_values: building.custom_field_values
      }
    end
  end
end
