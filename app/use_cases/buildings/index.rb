module Buildings
  class Index
    # Define Buildings::Index::Error
    class Error < StandardError; end

    def initialize(client)
      @client = client
    end

    def call
      {
        buildings: buildings_data
      }
    rescue StandardError => e
      # Use this domain to customize error handling behavior
      # ex: relabel internal error messages, cherry pick certain types of errors, etc
      custom_message = "Custom message: #{e.message}"
      raise Buildings::Index::Error, e.message
    end

    private

    attr_reader :client

    def buildings_data
      client_keys = client.custom_fields.flat_map { |cf| cf.schema_store.keys }.uniq

      client.buildings.map do |b|
        base = {
          id: b.id,
          client_name: b.client.name,
          address: b.address,
          zip_code: b.zip_code,
          state: b.state
        }

        # Merge custom fields; default to empty string if missing
        custom_data = client_keys.index_with { |key| b.custom_field_values[key] || "" }

        base.merge(custom_data)
      end
    end
  end
end
