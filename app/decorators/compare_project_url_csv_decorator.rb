# frozen_string_literal: true

class CompareProjectUrlCsvDecorator
  include ActionView::Helpers::UrlHelper

  def initialize(project, host)
    @project = project
    @host = host
  end

  def year_over_year_commits_url
    require_best_analysis do |a|
      f = a.factoids.find { |factoid| f.is_a?(FactoidActivity) || factoid.is_a?(FactoidTeamSizeZero) }
      h.project_factoids_url(@project, host: @host, anchor: (f ? f.class.name : 'FactoidActivityStable'))
    end
  end

  def comments_url
    require_best_analysis do |a|
      return t('compares.project_cells.comments.no_comments_found') unless a.relative_comments

      f = a.factoids.find { |factoid| factoid.is_a?(FactoidComments) }
      return h.project_factoids_url(@project, host: @host, anchor: f.class.name) if f

      t('compares.project_cells.comments.no_comments_found')
    end
  end

  def project_url
    h.project_url(@project, host: @host)
  end

  def estimated_cost_project_url
    h.estimated_cost_project_url(@project, host: @host)
  end

  def project_contributors_url(args = {})
    h.project_contributors_url(@project, args.merge(host: @host))
  end

  def project_contributors_url_last_twelve_months
    project_contributors_url(time_span: '12 months')
  end

  def project_contributors_url_last_thirty_days
    project_contributors_url(time_span: '30 days')
  end

  def project_commits_url(args = {})
    h.project_commits_url(@project, args.merge(host: @host))
  end

  def project_commits_url_last_twelve_months
    project_commits_url(time_span: '12 months')
  end

  def project_commits_url_last_thirty_days
    project_commits_url(time_span: '30 days')
  end

  def languages_summary_project_analysis_url
    h.languages_summary_project_analysis_url(@project, id: 'latest', host: @host)
  end

  def t(*args)
    I18n.t(*args)
  end

  private

  def require_best_analysis
    if !@project.best_analysis.nil? && @project.best_analysis.last_commit_time
      yield @project.best_analysis
    else
      @project.enlistments.count.positive? ? t('compares.pending') : t('compares.no_data')
    end
  end

  def h
    Rails.application.routes.url_helpers
  end
end
