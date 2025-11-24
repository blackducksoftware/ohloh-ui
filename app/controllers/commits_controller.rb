# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CommitsController < SettingsController
  helper ProjectsHelper

  before_action :set_project_or_fail
  before_action :find_commit, only: :show
  before_action :find_contributor_fact, only: %i[events event_details]
  before_action :redirect_to_message_if_oversized_project, except: :statistics
  before_action :set_sort_and_highlight, only: :index
  before_action :project_context, except: %i[statistics events event_details]
  skip_before_action :show_permissions_alert

  def index
    return if @project.best_analysis.empty?

    params[:contributor_id].present? ? individual_named_commits : named_commits
  end

  def show
    @diffs = @commit.diffs.includes(:fyle).filter_by(params[:query])
                    .order('fyles.name').page(page_param).per_page(10)
    @ignore_prefixes = @commit.code_set.ignore_prefixes(@project)
    @allow_prefixes = @commit.code_set.allow_prefixes(@project)
  end

  def summary
    @analysis = @project.best_analysis
    return if @project.best_analysis.empty?

    get_project_commits
    get_commit_contributors
  end

  def get_commit_contributors
    @commit_contributors = CommitContributor.includes(:name, :person)
                                            .where(analysis_id: @analysis.id)
                                            .where(name_id: @commits.map(&:name_id))
                                            .group_by(&:name_id)
  end

  def statistics
    @commit = Commit.find(params[:id])

    @lines_added, @lines_removed = @commit.lines_added_and_removed(@project.best_analysis_id)
    render layout: false
  end

  def events
    @daily_commits = @contributor_fact.daily_commits
    respond_to do |format|
      format.xml  { render layout: false }
    end
  end

  def event_details
    day_time = find_start_time
    @commits = @contributor_fact.commits_within(day_time, day_time.days_since(1))
    render layout: false
  end

  private

  def individual_named_commits
    get_commit_contributor
    return unless @commit_contributor

    @commits = Commit.joins(:analysis_aliases)
                     .where(code_set_id: @commit_contributor.code_set_id, name_id: @commit_contributor.name_id)
                     .where(commits: { position: ..@commit_contributor.code_set.as_of.to_i })
                     .where(analysis_aliases: { analysis_id: @commit_contributor.analysis_id })
                     .page(page_param).per_page(10)
  end

  def named_commits
    @analysis = @project.best_analysis
    return unless @project.best_analysis

    get_project_commits
    get_commit_contributors
  end

  def get_project_commits
    @commits = Commit.by_analysis(@analysis)
                     .within_timespan(params[:time_span], @analysis.oldest_code_set_time)
                     .filter_by(params[:query])
                     .order(time: :desc).page(page_param)
  end

  def find_commit
    @commit = Commit.find_by(id: params[:id])
    raise ParamRecordNotFound if @commit.nil?
  end

  def find_contributor_fact
    if @project.best_analysis_id
      @contributor_fact = ContributorFact.find_by(analysis_id: @project.best_analysis_id,
                                                  name_id: params[:contributor_id])
    end
    return if @contributor_fact

    notify_contributor_fact_not_found
    render_404
  end

  def notify_contributor_fact_not_found
    Airbrake.notify('ContributorFact Not Found for the give project') do |notice|
      notice[:parameters] = contributor_fact_error_parameters
      notice[:context] = contributor_fact_error_context
      notice[:session] = contributor_fact_error_session
    end
  end

  def contributor_fact_error_parameters
    {
      analysis_id: @project.best_analysis_id,
      name_id: params[:contributor_id],
      project_id: @project.id,
      backtrace: caller(0, 10)
    }
  end

  def contributor_fact_error_context
    {
      controller: self.class.name,
      action: action_name,
      request_id: request.request_id
    }
  end

  def contributor_fact_error_session
    {
      user_id: current_user&.id,
      session_id: session.id
    }
  end

  def find_start_time
    time_param = params[:time] =~ /commit_(\d+)/ ? $1 : params[:time]
    Time.at(time_param.to_i).in_time_zone.to_date
  end

  def redirect_to_message_if_oversized_project
    redirect_to root_path, notice: t('commits.project_temporarily_disabled') if oversized_project?(@project)
  end

  def get_commit_contributor
    @commit_contributor = @project.commit_contributors.find_by(contribution_id: params[:contributor_id])
  end
end
# rubocop:enable Metrics/ClassLength
