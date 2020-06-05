# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CompareProjectAnalysisCsvDecorator
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  def initialize(project)
    @project = project
  end

  def data_quality
    require_best_analysis { |a| t('compares.updated_ago', ago: time_ago_in_words(a.updated_on)) }
  end

  def estimated_cost
    require_best_analysis { |a| number_to_currency(a.cocomo_value.round, precision: 0) }
  end

  def initial_commit
    require_best_analysis { |a| t('compares.ago', ago: time_ago_in_words(a.first_commit_time)) }
  end

  def most_recent_commit
    require_best_analysis { |a| t('compares.ago', ago: time_ago_in_words(a.last_commit_time)) }
  end

  def year_over_year_commits
    require_best_analysis do |a|
      case a.factoids.find { |f| f.is_a?(FactoidActivity) || f.is_a?(FactoidTeamSizeZero) }
      when FactoidActivityIncreasing then t('compares.increasing')
      when FactoidActivityDecreasing then t('compares.decreasing')
      when FactoidTeamSizeZero then t('compares.no_activity')
      else t('compares.stable')
      end
    end
  end

  def comments
    require_best_analysis do |a|
      f = a.factoids.find { |factoid| factoid.is_a?(FactoidComments) }
      return t('compares.project_cells.comments.no_comments_found') unless a.relative_comments && f

      t("compares.project_cells.comments.#{f.class.name.gsub('FactoidComments', '').underscore}")
    end
  end

  def contributors_all_time
    require_best_analysis { |a| pluralize_with_delimiter(a.committers_all_time, t('compares.developer')) }
  end

  def contributors_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.committer_count, t('compares.developer')) }
  end

  def contributors_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.committer_count, t('compares.developer')) }
  end

  def commits_all_time
    require_best_analysis { |a| pluralize_with_delimiter(a.commit_count, t('compares.commit')) }
  end

  def commits_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.commits_count, t('compares.commit')) }
  end

  def commits_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.commits_count, t('compares.commit')) }
  end

  def files_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.files_modified, t('compares.file')) }
  end

  def files_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.files_modified, t('compares.file')) }
  end

  def loc
    require_best_analysis { |a| pluralize_with_delimiter(a.code_total, t('compares.line')) }
  end

  def loc_added_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.lines_added, t('compares.line')) }
  end

  def loc_removed_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.lines_removed, t('compares.line')) }
  end

  def loc_added_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.lines_added, t('compares.line')) }
  end

  def loc_removed_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.lines_removed, t('compares.line')) }
  end

  def main_language_name
    require_best_analysis { |a| a.main_language ? a.main_language.nice_name : t('compares.no_code_found') }
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

  def require_twelve_month
    require_best_analysis do
      tms = @project.best_analysis.twelve_month_summary
      return t('compares.no_data') if tms.nil?

      tms.committer_count.positive? ? yield(tms) : t('compares.no_activity')
    end
  end

  def require_thirty_day
    require_best_analysis do
      tds = @project.best_analysis.thirty_day_summary
      return t('compares.no_data') if tds.nil?

      tds.committer_count.positive? ? yield(tds) : t('compares.no_activity')
    end
  end
end
# rubocop:enable Metrics/ClassLength
