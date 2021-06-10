# frozen_string_literal: true

class FisJob < Job
  self.abstract_class = true
  self.table_name = 'fis.jobs'

  belongs_to :slave
  has_many :slave_logs

  class << self
    def stale_jobs_report(enlistments)
      report = dnf_source?(enlistments) ? { dnf_present: 1 } : {}

      incomplete_jobs = incomplete_fis_jobs.where(code_location_id: enlistments.pluck(:code_location_id))
      incomplete_jobs.pluck(:failure_group_id).each do |failure_group_id|
        failure_group_name = failure_group_patterns[failure_group_id]
        next unless failure_group_name

        report[failure_group_name] ||= 1
      end

      report
    end

    private

    def dnf_source?(enlistments)
      enlistments.any? { |en| en.code_location.do_not_fetch }
    end

    def failure_group_patterns
      # Converts "Connection Reset by Peer (SVN?)" to 'connection_reset_by_peer'.
      # e.g. output: { 11 => 'connection_reset_by_peer', 86 => 'investigate', ... }
      @failure_group_patterns ||= Hash[FailureGroup.pluck(:id, :name)
                                                   .map { |id, name| [id, underscore_and_clean(name)] }]
    end

    def underscore_and_clean(name)
      name.slice(/[\w|\s]+\w+/).downcase.gsub(' ', '_')
    end
  end
end
