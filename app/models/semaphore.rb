class Semaphore < ActiveRecord::Base
  EXECUTION_TYPES =  { job_candidate: 1, repo_jobs: 2 }

  belongs_to :slave

  class << self
    def with_lock(execution_type)
      fail 'execution block missing' unless block_given?
      semaphore = nil
      loop do
        sleep 1
        semaphore = create_lock(execution_type)
        break if semaphore
      end

      yield

      ensure
        semaphore.destroy
    end

    private

    def create_lock(execution_type)
      create(slave: Slave.local, execution_type: execution_type)
      rescue
        false
    end
  end
end
