class AliasesController < SettingsController
  helper ProjectsHelper
  before_action :session_required, :redirect_unverified_account, except: :index
  before_action :find_project, except: [:undo, :redo]
  before_action :redirect_to_message_if_oversized_project, only: :new
  before_action :project_context, only: [:index, :new]

  def index
    @best_analysis_aliases = Alias.best_analysis_aliases(@project)
    @aliases = Alias.for_project(@project).includes(:commit_name, :preferred_name)
  end

  def new
    @alias = Alias.new
    @committer_names = Alias.committer_names(@project)
  end

  def create
    Alias.create_for_project(current_user, @project, params[:commit_name_id], params[:preferred_name_id])
    redirect_to action: :index
  end

  def undo
    alias_record = Alias.find_by(id: params[:id], deleted: false)
    alias_record.create_edit.undo!(current_user) if alias_record
    redirect_to action: :index
  end

  def redo
    alias_record = Alias.find_by(id: params[:id], deleted: true)
    alias_record.create_edit.redo!(current_user) if alias_record
    redirect_to action: :index
  end

  def preferred_names
    @preferred_names = Alias.preferred_names(@project, params[:commit_name_id])
    render partial: 'aliases/preferred_names'
  end

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
    @project.editor_account = current_user
  end

  def redirect_to_message_if_oversized_project
    redirect_to message_path, notice: t('aliases.alias_temporarily_disabled') if oversized_project?(@project)
  end
end
