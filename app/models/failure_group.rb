class FailureGroup < ActiveRecord::Base
  has_many :jobs, -> { where(status: Job::STATUS_FAILED) }

  validates_presence_of :name, :pattern

  # Options include:
  # :job_id - The job ID you want to process. Default is to process all jobs
  # :force - If set to true, will re-categorize each job. Default is to only categorize un-categorized jobs
  # This is the direct database way of doing things. Force categorization time: 23 seconds (the ruby way was 78 seconds)
  # As I added more, this turned into: 258 seconds   So I will need to re-think this yet again at some point in the future
  def self.categorize(options={})
    if options[:force]
      sql = "UPDATE jobs SET failure_group_id = NULL WHERE status = #{Job::STATUS_FAILED}"
      if options[:job_id]
        sql << " AND id = #{options[:job_id]}"
      end
      sql << " AND failure_group_id IS NOT NULL"
      ActiveRecord::Base.connection.execute(sql)
    end

    failure_groups = FailureGroup.order('priority DESC, "name" ASC, "id" ASC')
    failure_groups.each do |failure_group|
      args = []
      sql = "UPDATE jobs"

      sql << " SET failure_group_id = ?"
      args.push(failure_group.id)

      sql << " WHERE status = ?"
      args.push(Job::STATUS_FAILED)

      if options[:job_id]
        sql << " AND id = ?"
        args.push(options[:job_id])
      end

      sql << " AND failure_group_id IS NULL"

      sql << " AND exception ILIKE ?"
      args.push(failure_group.pattern)

      args.insert(0, sql)

      inlineSQL = ActiveRecord::Base.send("sanitize_sql_array", args)
      ActiveRecord::Base.connection.execute(inlineSQL)
    end
  end

  def decategorize()
    jobs.each do |job|
      job.failure_group = nil
      job.save
    end
  end
end
