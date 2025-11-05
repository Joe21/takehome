class CustomField < ApplicationRecord
  belongs_to :client

  FIELD_TYPES = %w[number freeform enum].freeze

  validates :label, presence: true
  validates :key, presence: true, uniqueness: { scope: :client_id }
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validate :enum_options_required_if_enum

  private

  def enum_options_required_if_enum
    return unless field_type == 'enum'

    if enum_options.blank? || !enum_options.is_a?(Array) || enum_options.empty?
      errors.add(:enum_options, 'must be an array with at least one option for enum fields')
    end
  end
end
