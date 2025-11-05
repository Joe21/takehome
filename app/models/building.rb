class Building < ApplicationRecord
  belongs_to :client

  STATES = {
    AL: "AL", AK: "AK", AZ: "AZ", AR: "AR", CA: "CA", CO: "CO", CT: "CT", DE: "DE",
    FL: "FL", GA: "GA", HI: "HI", ID: "ID", IL: "IL", IN: "IN", IA: "IA", KS: "KS",
    KY: "KY", LA: "LA", ME: "ME", MD: "MD", MA: "MA", MI: "MI", MN: "MN", MS: "MS",
    MO: "MO", MT: "MT", NE: "NE", NV: "NV", NH: "NH", NJ: "NJ", NM: "NM", NY: "NY",
    NC: "NC", ND: "ND", OH: "OH", OK: "OK", OR: "OR", PA: "PA", RI: "RI", SC: "SC",
    SD: "SD", TN: "TN", TX: "TX", UT: "UT", VT: "VT", VA: "VA", WA: "WA", WV: "WV",
    WI: "WI", WY: "WY"
  }.freeze

  # Safe enum declaration to avoid Rails internal mapping violations when frozen
  enum :state, STATES.dup

  validates :address, presence: true, uniqueness: { scope: :client_id, case_sensitive: false }
  validates :state, presence: true, inclusion: { in: states.keys }
  # Validate U.S. zipcodes for 5 digits + optional 4 digit extension (12345-6789)
  validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }
end
