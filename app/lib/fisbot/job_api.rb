class JobApi < FisbotApi
  class << self
    def endpoint
      'jobs/project_jobs'
    end
  end
end
