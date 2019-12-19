# frozen_string_literal: true

module TimeStampHelper
  def project_analysis_timestamp(project)
    analysis = project.best_analysis
    render partial: '/shared/analysis_timestamp', locals: { analysis: analysis, project: project } unless analysis.nil?
  end

  SECONDS = 60
  SECS_PER_MIN = SECONDS * 60
  SECS_PER_DAY = SECS_PER_MIN * 24
  # NOTE: this is not internationalized because it's currently only used in the ActiveAdmin UI
  def time_ago_in_days_hours_minutes(time)
    return 'not available' unless time

    seconds_since = Time.current.utc - time
    days = (seconds_since / SECS_PER_DAY).to_i
    hours = ((seconds_since % SECS_PER_DAY) / SECS_PER_MIN).to_i
    minutes = (((seconds_since % SECS_PER_DAY) % SECS_PER_MIN) / SECONDS).to_i
    "#{days}d #{hours}h #{minutes}m"
  end
end
