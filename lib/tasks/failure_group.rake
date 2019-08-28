# frozen_string_literal: true

namespace :jobs do
  desc 'Fix Job Failures'
  task reschedule_failure_group: :environment do
    retry_delays = [3.hours, 12.hours, 1.day, 2.days, 4.days, 1.week, 2.weeks, 1.month, 2.months]
    failures = FailureGroup.select(:pattern).where(auto_reschedule: true).order(:id)
    exit(1) if failures.empty?

    failures.each do |failure|
      failed_jobs = Job.failed.where('exception ILIKE ?', failure.pattern)
                       .where('do_not_retry IS FALSE')
                       .where('retry_count < ? ', retry_delays.size)
      exit(1) if failed_jobs.empty?

      failed_jobs.find_in_batches(batch_size: 100) do |jobs|
        jobs.each do |job|
          job.status = Job::STATUS_SCHEDULED
          job.slave = nil
          job.wait_until = (job.current_step_at || Time.now.utc) + retry_delays[job.retry_count]
          job.retry_count += 1
          job.notes = job.notes.to_s + "Auto-rescheduled #{Time.now.utc}\n"
          job.save!
        end
      end
    end
  end
end
