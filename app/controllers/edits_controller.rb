class EditsController < SettingsController
  helper ProjectsHelper

  before_action :session_required, only: [:update]
  before_action :find_parent, only: [:index]
  before_action :find_edit, only: [:update]
  before_action :find_edits, only: [:index]

  def index
    render template: "edits/index_#{@parent.class.name.downcase}"
  end

  def update
    undo = params[:undo].to_bool
    undo ? @edit.undo!(current_user) : @edit.redo!(current_user)
    render template: 'edits/edit', layout: false
  rescue StandardError
    render text: undo ? t('.failed_undo') : t('.failed_redo'), status: 406
  end

  private

  def find_parent
    @parent = find_account || find_project || find_organization || find_license
    fail ParamRecordNotFound unless @parent
    send("#{@parent.class.name.downcase}_context") unless @parent.is_a?(License)
  end

  def find_account
    return nil unless params[:account_id]
    Account.from_param(params[:account_id]).take
  end

  def find_project
    return nil unless params[:project_id]
    Project.from_param(params[:project_id]).take
  end

  def find_organization
    return nil unless params[:organization_id]
    Organization.from_param(params[:organization_id]).take
  end

  def find_license
    return nil unless params[:license_id]
    License.from_param(params[:license_id]).take
  end

  def find_edit
    @edit = Edit.where(id: params[:id]).first
    fail ParamRecordNotFound unless @edit
  end

  def find_edits
    edits = Edit.page(params[:page]).per_page(10).order('edits.created_at DESC, edits.id DESC')
    @edits = add_query_term(add_robotic_term(add_where_term(edits)))
  end

  def add_where_term(edits)
    target_where = '(edits.target_id = ? AND edits.target_type = ?)'
    extra_where = add_where_extra_clause
    if extra_where
      edits.where(["#{target_where}#{extra_where}", @parent.id, @parent.class.name.tableize, @parent.id])
    else
      edits.where([target_where, @parent.id, @parent.class.name])
    end
  end

  def add_where_extra_clause
    return nil unless [Account, Project, Organization].include?(@parent.class)
    " OR edits.#{@parent.class.name.downcase}_id = ?"
  end

  def add_robotic_term(edits)
    non_human_ids = params[:human].to_bool ? (Account.non_human_ids) : [0]
    edits.where.not(account_id: non_human_ids)
  end

  def add_query_term(edits)
    query_term = params[:q] || params[:query]
    query_term ? edits.filter_by(query_term) : edits
  end
end
