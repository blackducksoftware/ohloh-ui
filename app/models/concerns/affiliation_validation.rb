module AffiliationValidation
  extend ActiveSupport::Concern

  ALLOWED_AFFILIATION_TYPES = %w(unaffiliated other specified)

  included do
    validates :organization_name, length: { in: 3..85 },
                                  format: { with: /\A[a-zA-Z0-9][\w\s.,-_]*\Z/u },
                                  allow_blank: true

    validate :allowed_affiliation_type
    validate :affiliation_by_organization_id
    validate :affiliation_by_organization_name
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

  def affiliation_by_organization_id
    errors.add(:organization_id, I18n.t(:cant_be_blank)) if organization_id.blank? && affiliation_type_specified?
    self.organization_name = nil
  end

  def affiliation_by_organization_name
    errors.add(:organization_name, I18n.t(:cant_be_blank)) if organization_name.blank? && affiliation_type_specified?
    self.organization_id = nil
  end
end
