class Building < ApplicationRecord
  belongs_to :client

  enum :state, {
    AL: "AL", AK: "AK", AZ: "AZ", AR: "AR", CA: "CA",
    CO: "CO", CT: "CT", DE: "DE", FL: "FL", GA: "GA",
    HI: "HI", ID: "ID", IL: "IL", IN: "IN", IA: "IA",
    KS: "KS", KY: "KY", LA: "LA", ME: "ME", MD: "MD",
    MA: "MA", MI: "MI", MN: "MN", MS: "MS", MO: "MO",
    MT: "MT", NE: "NE", NV: "NV", NH: "NH", NJ: "NJ",
    NM: "NM", NY: "NY", NC: "NC", ND: "ND", OH: "OH",
    OK: "OK", OR: "OR", PA: "PA", RI: "RI", SC: "SC",
    SD: "SD", TN: "TN", TX: "TX", UT: "UT", VT: "VT",
    VA: "VA", WA: "WA", WV: "WV", WI: "WI", WY: "WY"
  }

  validates :address, presence: true,
                      uniqueness: { scope: :client_id, case_sensitive: false }
  validates :zip5, presence: true,
                   length: { is: 5 },
                   format: { with: /\A\d{5}\z/, message: "must be 5 digits" }
  validates :state, presence: true,
                    inclusion: { in: states.keys }
end
