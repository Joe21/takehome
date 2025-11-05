# Notes

### Milestones
- Set up
  - Pull repo, initialize container
  - QoL aliases
    `alias qq="cd ~/Desktop/Takehome/engineering_take_home"`
    `alias ds="docker compose exec web bash`
    `alias dt="docker compose exec web bash -c 'RAILS_ENV=test bundle exec rspec'"`
  - Initialize DB
  - Happy path rails s + welcome_spec
- Map out Data Modeling
- Build Models
- Build validation engine
- API
  - Buildings#index
    - pagination
  - Buildings#create
  - Buildings#update


### DATA MODELING
- Client
  - id
  - name (unique, case insensitive / citext or not? Store the casing but ensure no dupes)
  - timestamps
- Building
  - id
  - address     (string)
  - state       (Enum)
  - zip5        (int, limit 5)
  - client_id
- CustomField
  - id
  - key (string, unique)
  - label (string, unique)
  - field_type (enum numer, string, enum)
  - enum_options (default: [])
  - active (boolean, default: false)
  - client_id
  - timestamps
- CustomValues
  - id
  - building_id
  - custom_field_id
  - value (jsonb)

### RELATIONSHIPS
- client has_many :buildings
- client has_many :custom_fields
- building belongs_to :client
- building has_one :custom_value
- custom_value belongs_to :building
- custom_field belongs_to :client

### CONSIDERATIONS
- All custom_values must be owned by a building. Clients should not get separate versions of a walkway to the same building
- Avoid database duplication. We need a multi tenant configurable schema
- Not required but essentially allow us to CRUD a data contract per client. Allow what shared data each client can pluck from the single source of custom data truth.
- Envision data models that will increase volatility and irregularity as we scale
- Persist presentational logic for custom field labels (this saves the FE time for what is typically clientside responsibility but we are the source of truth, not their hardcoded conditional logic)
- JSONB
  - Pros:
    - Adding/removing fields doesn’t require migrations
    - Flexibility: Each building can have a variable number of fields
    - Limit table growth
    - Validation changes are not tied to expensive DB schema migrations (avoid polymoprhic at scale)
  - Cons:
    - Harder to query by individual key
    - App is repsonsible for validation logic
    - Indexing K/V can become troublesome when nested
  - Resolution:
    - Add GIS indexing to boost performance for filtering
    - Establish convention to never embed K/V for future PR reviews / codify this pattern
  - Additional Consideration:
    - We can technically add formal columns for text, number, date to custom_values and only use the json as a fallback further limiting JSONB structuring but the hybrid approach seems unattractive for more reasons.
- We should segregate the custom_values table and only include them explicitly for eager loading. The assumption is that not all clients may require the meta data or various service levels support that level of data provisioning to start with.

- Local VCS Strategy (joejung/submission_master)
  - [merged] initialize
  - [merged] plan_data_modeling 
  - create_data_models
