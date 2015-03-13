module TimeStampHelper
  def project_analysis_timestamp(project)
    analysis = project.best_analysis
    render partial: '/shared/analysis_timestamp', locals: { analysis: analysis, project: project } unless analysis.nil?
  end
end
