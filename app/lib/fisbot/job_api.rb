class JobApi < FisbotApi
  def initialize(project_id, page)
    @endpoint = 'jobs/project_jobs'
    @data = { id: project_id, page: page || 1 }
  end
end
