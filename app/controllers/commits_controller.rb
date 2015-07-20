class CommitsController < SettingsController
  helper ProjectsHelper

  before_action :set_project_or_fail
  before_action :find_named_commit, only: :show
  before_action :find_contributor_fact, only: [:events, :event_details]
  before_action :redirect_to_message_if_oversized_project, except: :statistics
  before_action :set_sort_and_highlight, only: :index
  before_action :project_context, except: [:statistics, :events, :event_details]
  skip_before_action :show_permissions_alert

  def index
    @named_commits = @project.named_commits
                     .includes(:commit, :person, :account)
                     .filter_by(params[:query])
                     .send(parse_sort_term)
                     .page(params[:page])
                     .per_page(20)
  end

  def show
    @diffs = @named_commit.commit.diffs
             .includes(:fyle)
             .filter_by(params[:query])
             .order('fyles.name')
             .page(params[:page])
             .per_page(10)
    @ignore_prefixes = @named_commit.code_set.ignore_prefixes(@project)
  end

  def summary
    @analysis  = @project.best_analysis
    @named_commits = @analysis.named_commits.includes(:commit).by_newest.limit(10) unless @analysis.nil?
  end

  def statistics
    @commit = Commit.find(params[:id])
    @lines_added, @lines_removed =  @commit.lines_added_and_removed(@project.best_analysis_id)
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

  def find_named_commit
    @named_commit = NamedCommit.find_by(id: params[:id])
    fail ParamRecordNotFound if @named_commit.nil?
  end

  def find_contributor_fact
    @contributor_fact  = ContributorFact.find_by(analysis_id: @project.best_analysis_id,
                                                 name_id: params[:contributor_id])
  end

  def parse_sort_term
    NamedCommit.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_newest'
  end

  def find_start_time
    time_param = params[:time] =~ /commit_(\d+)/ ? $1 : params[:time]
    time_param = Time.at(time_param.to_i)
    Time.new(time_param.year, time_param.month, time_param.day)
  end

  def redirect_to_message_if_oversized_project
    redirect_to root_path, notice: t('commits.project_temporarily_disabled') if oversized_project?(@project)
  end
end
