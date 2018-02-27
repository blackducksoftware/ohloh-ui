class JobApi < FisbotApi
  class << self
    def resource
      'jobs/project_jobs'
    end
  end
end
