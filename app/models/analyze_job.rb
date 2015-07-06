class AnalyzeJob < Job
  def progress_message
    "Analyzing project #{project.name}"
  end
end
