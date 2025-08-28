# frozen_string_literal: true

class FisJob < Job
  self.abstract_class = true
  self.table_name = 'fis.jobs'

  belongs_to :slave, optional: true
  has_many :slave_logs

  class << self
    def stale_jobs_report(enlistments)
      report = dnf_source?(enlistments) ? { dnf_present: 1 } : {}

      incomplete_fis_jobs.where(code_location_id: enlistments.select(:code_location_id))
                         .pluck(:failure_group_id).each do |failure_group_id|
        failure_group_name = failure_group_patterns[failure_group_id]
        next unless failure_group_name

        report[failure_group_name] ||= 1
      end

      report
    end

    def ransackable_attributes(_auth_object = nil)
      authorizable_ransackable_attributes
    end

    def ransackable_associations(_auth_object = nil)
      authorizable_ransackable_associations
    end

    private

    def dnf_source?(enlistments)
      enlistments.exists?(['code_locations.do_not_fetch is true'])
    end

    def failure_group_patterns
      # Converts "Connection Reset by Peer (SVN?)" to 'connection_reset_by_peer'.
      # e.g. output: { 11 => 'connection_reset_by_peer', 86 => 'investigate', ... }
      # rubocop:disable Style/HashTransformValues
      # False positive: array wont respond to transform_values.
      @failure_group_patterns ||= FailureGroup.pluck(:id, :name)
                                              .to_h { |id, name| [id, underscore_and_clean(name)] }
      # rubocop:enable Style/HashTransformValues
    end

    def underscore_and_clean(name)
      name.slice(/[\w|\s]+\w+/).downcase.gsub(' ', '_')
    end
  end
end
