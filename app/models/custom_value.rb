class CustomValue < ApplicationRecord
  belongs_to :building

  validates :values, presence: true
end
