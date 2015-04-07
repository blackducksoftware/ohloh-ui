class AutocompletesController < ApplicationController
  before_action :check_for_project, only: :contributions

  # NOTE: Replaces accounts#autocomplete,
  def account
    accounts = Account.simple_search(params[:term])
    render json: accounts.map { |a| { login: a.login, name: a.name, value: a.login } }
  end

  # NOTE: Replaces projects#autocomplete.
  def project
    @projects = Project.not_deleted
                .where('lower(name) like ?', "%#{ params[:term] }%")
                .where.not(id: params[:exclude_project_id].to_i)
                .order('length(name)')
                .limit(25)
  end

  def licenses
    licenses = params[:term] ? License.autocomplete(params[:term]) : []
    render text: licenses.map { |l| { nice_name: l.nice_name, id: l.id.to_s } }.to_json
  end

  # NOTE: Replaces contributions#autocomplete
  def contributions
    search_term = "%#{params[:term].strip.downcase}%"
    name_facts = NameFact.where(analysis_id: @project.best_analysis_id)
                  .where(['lower(names.name) like ? ', search_term])
                  .includes(:name).references(:all).order('names.name ASC').limit(10)
    render json: name_facts.map { |nf| nf.name.name }
  end

  private

  def check_for_project
    project_name = params[:project].to_s.strip.downcase
    @project = Project.active.where(['lower(name) = ?', project_name]).first unless project_name.empty?
    render text: '' if @project.nil? || @project.best_analysis_id.nil?
  end
end
