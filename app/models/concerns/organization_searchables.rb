# frozen_string_literal: true

module OrganizationSearchables
  extend ActiveSupport::Concern

  included do
    def searchable_vector
      {
        a: split_name_if_camecase_present,
        c: projects.map(&:name).join(' '),
        d: description
      }
    end

    def searchable_factor
      projects_count = Project.not_deleted.count
      return 0.0 if projects_count.zero? || projects_count.zero?

      Math.log10(projects_count * 2) / Math.log10(projects_count * 2)
    end

    private

    def split_name_if_camecase_present
      "#{(name.split + name.titleize.split).uniq.join(' ')} #{vanity_url}"
    end
  end
end
