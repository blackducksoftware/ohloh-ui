class CompleteJob < Job
  attr_reader :progress_message

  class << self
    def try_create(code_set, priority)
      job = Job.where(code_set: code_set)
            .where("status != ? OR current_step_at > NOW() AT TIME ZONE 'UTC' - INTERVAL '5 minutes'",
                   Job::STATUS_COMPLETED)
            .first

      return if job

      CompleteJob.create!(code_set_id: code_set.id, repository_id: code_set.repository_id, priority: priority)
    end
  end
end
