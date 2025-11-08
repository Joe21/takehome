module Buildings
  class Index
    class Error < StandardError; end

    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 25

    def initialize(client, page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE)
      @client = client
      @page = page.to_i <= 0 ? DEFAULT_PAGE : page.to_i
      @per_page = per_page.to_i <= 0 ? DEFAULT_PER_PAGE : per_page.to_i
    end

    def call
      paginated_buildings = client.buildings.offset((page - 1) * per_page).limit(per_page)

      {
        buildings: buildings_data(paginated_buildings),
        pagination: {
          page: page,
          per_page: per_page,
          total_count: client.buildings.count,
          total_pages: (client.buildings.count / per_page.to_f).ceil
        }
      }
    rescue StandardError => e
      raise Buildings::Index::Error, e.message
    end

    private

    attr_reader :client, :page, :per_page

    def buildings_data(buildings_scope)
      buildings_scope.map do |b|
        # Start with address info and client name
        building_hash = {
          id: b.id,
          client_name: client.name,
          address: b.address,
          zip_code: b.zip_code,
          state: b.state
        }

        # Merge in all client custom fields, filling defaults if missing
        client.custom_fields.each do |cf|
          cf.schema_store.each do |key, type|
            building_hash[key] = b.custom_field_values.key?(key) ? b.custom_field_values[key] : default_value_for(type)
          end
        end

        building_hash
      end
    end

    def default_value_for(type)
      case type
      when "number"
        0
      when "string", Array
        "" # includes enums as empty string
      else
        ""
      end
    end
  end
end
