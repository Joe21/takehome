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

### Design
- We are building a client facing abstraction layer. Custom values are responsible from the building owner/rep. They are not coming from an internal data warehouse or other source of truth. Volatility / resolution of custom_fields is not our operational perview. 
- External API consumers are going to receive all custom fields and values provided by the owner.
- CRUD data is destroyed. There is no implicit reason for us to save changes and nor have to revert back to previous values by client request. 
- Clients can change and reuse our system. Buildings can have multiple custom_fields per 
- We are not responsible for the source of truth, that is the responsiblity of the clients who CRUD their data using our platform. No need to support migrations and other data sanitization operations from a data warehouse source.

##### Pure Relational Design
- Implementation
  - Clients have buildings 
  - Buildings have many custom_fields per client_id
  - custom_fields has 3 types and houses validation logic
- Pros
  - Simple, flat 3 models, pure SQL. Easy to work with, query + filter
- Cons
  - Assuming buildings easily have hundreds of custom_fields, field changes become expensive transactions.
  - Ownership changes will occur frequently as well during the lifetime of this application.
- Considerations
  - We can async updates into a job. External api consumption is no longer guaranteed to provide real time data
  - Cost of transactions will continue to become more expensive at scale but async would provide a manageable medium term solution at reasonable cost.

##### NOSQL Integrated Design
- Implementation
  - Add a long term NoSQL DB to house the dynamic data needs for custom_fields. Something like Mongo or maybe Dynamo.
  - We store all the custom_field data along with the building_id an client_id to the document.
- Pros
  - Fast look ups using building_id and client_id indexes.
  - Fast writes as transactions are 1 shot, long term scale is alleviated.
- Cons
  - Additional overhead added to the stack.
  - Find the right DB and provider to ensure it is not overkill / cost prohibitive

##### HYBRID - TAKE HOME APPROPRIATE
- Implementation
  - Design for a NoSQL solution but for now, prove the MVP to scale by implementing JSONB into the rails application to act as a temporary K/V storage
- Pros
  - Uses the infrastructure we already have
  - Avoids overkill solution we may not have 
  - Easy lift to migrate this pattern over to a dedicated NoSQL solution
- Cons
  - JSONB usage in a relational database can be viewed as an anti-pattern, especially if left unchecked
  - Possibly more cumbersome to run analytics

### Implementation Considerations
- Keep the SQL side extremely easy
- The K/V storage must stay flat. Do not embed or introduce complex objects!
  - Denote type in key name using some sort of delimiter
  - Store data contract for enum types in yaml for now (short term MVP approach)
- Manage client custom_fields as a schema_store
- Manage the actual custom data on the buildings via 
- 2 separate controllers for different stakeholders (namespaced for clients mutating buildings vs external buildings api + eager load the custom_fields)

##### Older Debunked Considerations
[AVOID THIS] Storing the single source of truth per building / warehousing the data and then allowing clients to cherry pick + relabel their data. This is not a consideration we need to support atm. In this scenario external API consumers may want to CRUD custom_fields so we can persist their preference and they can customize the shape of their payload. 
- data duplication for multi tenant uses
- irregularity of data and frequent schema changes + migrations
- CRUD relabeling presentational values per client per custom_field
- Add GIS indexing on keys to ensure quick filtering and querying

### Each Branch is essentially a ticket
Local VCS Strategy (joejung/submission_master)
- [merged] initialize
- [merged] plan_data_modeling 
- [merged] create_data_models
- [merged] revise_data_models
- [x] separate_schema_and_data 
- [] seed_file
- [] controller
- [] cleanup