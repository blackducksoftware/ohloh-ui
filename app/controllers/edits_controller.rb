# frozen_string_literal: true

class EditsController < SettingsController
  helper ProjectsHelper

  before_action :session_required, :redirect_unverified_account, only: [:update]
  before_action :find_parent, only: %i[index show update refresh]
  before_action :show_permissions_alert, only: :index, unless: :parent_is_account_or_license?
  before_action :find_edit, only: %i[show update refresh]
  before_action :find_edits, only: [:index]

  def index
    render template: "edits/index_#{@parent.class.name.downcase}"
  end

  def show
    head :ok unless request.xhr?
  end

  def refresh
    render template: 'edits/edit', layout: false
  end

  def update
    undo = params[:undo].to_bool
    undo ? perform_undo : @edit.redo!(current_user)
    render template: 'edits/edit', layout: false
  rescue StandardError
    render plain: undo ? t('.failed_undo') : t('.failed_redo'), status: :not_acceptable
  end

  private

  def perform_undo
    @edit.undo!(current_user)
  end

  def parent_is_account_or_license?
    params[:account_id].present? || params[:license_id].present?
  end

  def find_parent
    @parent = find_account || find_project || find_organization || find_license
    raise ParamRecordNotFound unless @parent

    send("#{@parent.class.name.downcase}_context") unless @parent.is_a?(License)
  end

  def find_account
    return nil unless params[:account_id]

    Account.from_param(params[:account_id]).take
  end

  def find_project
    return nil unless params[:project_id]

    Project.by_vanity_url_or_id(params[:project_id]).take
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
    raise ParamRecordNotFound unless @edit
  end

  def find_edits
    params[:sort] = params[:sort] || 'updated_at'
    edits = Edit.page(page_param).per_page(10).order("edits.#{params[:sort]} DESC, edits.id DESC")
    @edits = add_query_term(add_robotic_term(add_where_term(edits)))
  end

  def add_where_term(edits)
    target_where = '(edits.target_id = ? AND edits.target_type = ?)'
    extra_where = add_where_extra_clause
    if params[:enlistment] == 'true'
      enlist_filter = 'edits.target_type = ? AND edits.project_id = ? AND key is NULL'
      edits.where([enlist_filter, 'Enlistment', @parent.id])
    elsif extra_where
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
    non_human_ids = params[:human].to_bool ? Account.non_human_ids : [0]
    edits.where.not(account_id: non_human_ids)
  end

  def add_query_term(edits)
    query_term = params[:q] || params[:query]
    query_term ? edits.filter_by(query_term) : edits
  end
end
