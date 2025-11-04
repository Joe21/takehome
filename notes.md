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
  - name (unique, case insensitive. Store the casing but ensure no dupes)
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
  - Shift data dependencies out of the DB and into the class layer via validation engine
  - Utilize GIS indexing for performance needs (less than 150m homes in the US, should suffice). Convention to gatekeep nested data

- Local VCS Strategy (joejung/submission_master)
  - [merged] initialize
  - [merged] plan data modeling 
  - create_clients
  - create_buildings
  - create_custom_fields
