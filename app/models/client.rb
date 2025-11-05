class Client < ApplicationRecord
  before_validation -> { self.name = name.strip }, if: -> { name.present? } 

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
