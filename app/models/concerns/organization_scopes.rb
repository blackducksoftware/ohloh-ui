# frozen_string_literal: true

module OrganizationScopes
  extend ActiveSupport::Concern

  included do
    scope :from_param, lambda { |param|
      active.where(Organization.arel_table[:vanity_url].eq(param).or(Organization.arel_table[:id].eq(param)))
    }
    scope :active, -> { where.not(deleted: true) }
    scope :managed_by, lambda { |account|
      joins(:manages).where.not(deleted: true, manages: { approved_by: nil }).where(manages: { account_id: account.id })
    }
    scope :case_insensitive_vanity_url, ->(mixed_case) { where(['lower(vanity_url) = ?', mixed_case.downcase]) }
    scope :sort_by_newest, -> { order(created_at: :desc) }
    scope :sort_by_recent, -> { order(updated_at: :desc) }
    scope :sort_by_name, -> { order(arel_table[:name].lower) }
    scope :sort_by_projects, -> { order('COALESCE(projects_count, 0) DESC') }
  end
end
