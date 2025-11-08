# NOTES

### Milestones
- Set up
  - Pull repo, initialize container
  - QoL aliases
    `alias qq="cd ~/Desktop/Takehome/engineering_take_home"`
    `alias ds="docker compose exec web bash`
    `alias dt="docker compose exec web bash -c 'RAILS_ENV=test bundle exec rspec'"`
  - Initialize DB
  - Happy path rails s + welcome_spec
- Map out data modeling
- Build Models
- Build validation engine
- API
  - Buildings#index
    - use case
    - error_handling
    - pagination
  - Buildings#create
    - use case
    - error_handling
  - Buildings#update
    - use case
    - error_handling
- Local test postman / bruno
- Clean up via rubocop omakase


### DATA MODELING
- Client
  - id
  - name                (index on lower name to ensure uniqueness + look ups)
  - timestamps
- Building
  - id
  - client_id           (index)
  - address             (string - index on lower to ensure uniqueness + look ups)
  - zip_code            (string - allow extentions,  index_buildings_on_state_and_zip_code)
  - state               (enum, index_buildings_on_state_and_zip_code)
  - custom_field_values (jsonb - gis index)
  - timestamps
- CustomField
  - id
  - client_id           (index)
  - schema_store        (jsonb)
  - timestamps


### RELATIONSHIPS
- client has_many :buildings
- client has_many :custom_fields
- building belongs_to :client
- custom_field belongs_to :client


### SYSTEM DESIGN
- Avoid storing schema related persistence in SQL as this will not scale well
  - A new row for each custom_field associated to building
  - If clients change building ownership and the building remains the single source of truth, this will increase record count
  - If custom_field definitions and classifications change enums change, schematic migrations are more expensive and could require downtime. 
  - Transactions could become expensive. We would async them to a job / worker but that is a mid term solution and we must consider if the API is servicing a web interface, we'd need notification to inform clients when transactions complete as they are no longer guaranteeable in real time.
- Segregate schema and values
  - custom_fields.schema_store: Persist the allowed types and structure of metadata
    ```
    {
      "num_bathrooms" => "number",
      "exterior_material" => "string",
      "walkway_type" => ["brick", "concrete", "none", "unknown"]
    }
    ```
  - building.custom_field_values: Persist the buildings metadata
    ```
    {
      "num_bathrooms"   => 2,
      "exterior_material" => "Wood",
      "walkway_type"    => "concrete",
      "heating_type"    => "gas"
    }
    ```
- Store schema in custom_fields jsonb
  - Keep the json column flat to avoid introducing code smells
  - Changing ownership of buildings will always only cost a single record to update
  - Validation engine exists in the app's code instead of DB schema. Lower maintenance cost at long term scale as DB migrations of large tables can easily require downtime / maintenance windows, orchestration of other jobs / data ingestion / multiple consumers, etc.
- Use the jsonb as a temporary hold until we prove we need a dedicated NoSQL database to introduce to the stack (mongo, dynamodb, etc)
  - I thought about moving the custom_field_values into a separate table and segregating that from the buildings table but this seemed unnecessary for the time being


### DESIGN PATTERNS / CONSIDERATIONS
- Try to adhere to REST conventions and designs for now. Avoid nesting buildings and clients resource, in real life we'd extract the client from auth token
- Mock current_client as Client.first for now
- Utilize use cases per route
  - Avoid catching errors from the controller and the service object
  - Controllers should test for status and shape. Not for content and business logic. 
  - Clear segregation of business logic testing when comparing the test suites btwn controller and use case
- Ensure appropriate status and status codes
- Should have probably associates custom_field_values on a separate table with a has_one to with building. Might be easier for a lift and shift to NoSQL later
- Avoid nesting jsonb. Always guard against throwing the kitchen sink into K/V storage


### FEATURES
- Fully tested
- More sophisticated error handling: 
  - Use cases aren't necessary on microservices but have proven really useful in monoliths. Segregation of error handling and customization allows for a nice, centralized domain and a easy to maintain pattern (a little verbose I admit)
    - ActiveRecord Errors: Probably want to ignore these. 404 thats on the client
    - Validation errors: I don't want a sentry / rollbar. 422 on the client
    - How to handle unknown errors: Something we didn't plan for occurred. Send me a rollbar because this is a 500
- Pagination
- GIS indexing on the json column for faster key/value look ups with postgre
- zip_code validation allows for 4 digit extension
- Address validation handles uniqueness issues and prevents casing dupes


##### EARLIER MISTAKES
- Thought we were building a client facing abstraction layer. Missed the snippet that clients cannot edit their K/V and thought that was the goal was to lay a foundation later where clients could edit them
  - This does seem somewhat realistic as the scenario does not details how/who sets the custom_field definitions per client. We may want to separate clients/admins who can CRUD those definitions down the line.
- Assuming the buildings are a source of truth for future transactions. If this is a data warehousing issue or if the app must contain long term useage of the same building identifier. Customer A owns Building 123. Customer B buys is and lists it. Can this be a new record or must be maintain identity and update it (hence the need for address uniqueness, though this may not really be a string).
- Can external API consumers see all the metadata for non owned buildings? Does anyone ever have to?
- Logging and maybe reverts to changes to the JSONB. Do we need version control?
- As ownership changes do buildings.custom_field_values retain all the different types of customer-centric custom_fields? Should these be separate records? Should an internal taxnomy be adopted where clients essentially crud their labels for the json output? More like a localization crud function.


### Each Branch is essentially a ticket
Local VCS Strategy (joejung/submission_master)
- [merged] initialize
- [merged] plan_data_modeling 
- [merged] create_data_models
- [merged] revise_data_models
- [merged] separate_schema_and_data 
- [merged] create_controllers
  - [x] setup
  - [x] payload
  - [x] index
  - [x] pagination
  - [x] create
  - [x] update
- [merged] cleanup + update notes

# Snippets
docker-compose up -d db
docker-compose run --rm --service-ports web bash
bundle exec rails s -b 0.0.0.0 -p 3000

./bin/rubocop
./bin/rubocop -a