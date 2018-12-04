module AffiliationValidation
  extend ActiveSupport::Concern

  ALLOWED_AFFILIATION_TYPES = %w[unaffiliated other specified].freeze

  included do
    validates :organization_name, length: { in: 3..85 },
                                  format: { with: /\A[a-zA-Z0-9][\w\s.,-_]*\Z/u },
                                  allow_blank: true

    validate :allowed_affiliation_type
    validates :organization_id, presence: true, if: :affiliation_type_specified?
    validates :organization_name, presence: true, if: :affiliation_type_other?
  end

  ALLOWED_AFFILIATION_TYPES.each do |type|
    define_method "affiliation_type_#{type}?".to_sym do
      affiliation_type.to_s == type
    end
  end

  private

  def allowed_affiliation_type
    errors.add(:affiliation_type, I18n.t(:is_invalid)) unless ALLOWED_AFFILIATION_TYPES.include?(affiliation_type.to_s)
  end
end
