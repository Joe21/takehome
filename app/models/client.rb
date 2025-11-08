class Client < ApplicationRecord
  has_many :buildings
  has_many :custom_fields

  before_validation -> { self.name = name.strip }, if: -> { name.present? }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
