module AffiliationValidation
  extend ActiveSupport::Concern
  ALLOWED_AFFILIATION_TYPES = %w(unaffiliated other specified)
  included do
    validate :organization_name, length: { in: 3..85 },
                                 format: { with: /^[a-zA-Z0-9][\w\s.,-_]*$/u },
                                 if: proc { |p| p.organization_name.present? },
                                 message: 'should start with a letter and can include only letters, numbers, _ and -'
    validate :affiliation_existence
    validate :affiliation_by_organization_id
    validate :affiliation_by_organization_name
  end

  ALLOWED_AFFILIATION_TYPES.each do |type|
    define_method "affiliation_type_#{type}?".to_sym do
      affiliation_type.to_s == type
    end
  end

  def affiliation_existence
    errors.add(:affiliation_type, 'is invalid') unless ALLOWED_AFFILIATION_TYPES.include?(affiliation_type.to_s)
  end

  def affiliation_by_organization_id
    errors.add(:organization_id, 'can\'t be blank') if organization_id.blank? && affiliation_type_specified?
    self.organization_name = nil
  end

  def affiliation_by_organization_name
    errors.add(:organization_name, 'can\'t be blank') if organization_name.blank? && affiliation_type_specified?
    self.organization_id = nil
  end
end
