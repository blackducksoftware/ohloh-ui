class CompleteJob < Job
  def initialize(args={})
    super(args)
    @progress_message = "Starting"
  end

  class << self
    def try_create(code_set, priority = 0)
      code_set.wait_lock do
        connection.execute <<-SQL
          INSERT INTO jobs (type, repository_id, code_set_id, priority)
          (SELECT 'CompleteJob', #{code_set.repository_id}, #{code_set.id}, #{priority}
          WHERE NOT EXISTS (
            SELECT * FROM jobs WHERE code_set_id=#{code_set.id}
            AND (status != #{Job::STATUS_COMPLETED} OR current_step_at > NOW() AT TIME ZONE 'UTC' - INTERVAL '5 minutes')
          ));
        SQL
      end
      nil
    end
  end
end
