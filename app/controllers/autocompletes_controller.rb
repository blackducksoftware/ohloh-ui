class AutocompletesController < ApplicationController
  before_action :check_for_project, only: :contributions
  before_action :set_name_facts, only: :contributions

  def account
    accounts = Account.simple_search(params[:term])
    render json: accounts.map { |a| { login: a.login, name: a.name, value: a.login, id: a.id } }
  end

  def project
    @projects = Project.not_deleted
                .where('lower(name) like ?', "%#{ params[:term].downcase }%")
                .where.not(id: params[:exclude_project_id].to_i)
                .order('length(name)')
                .limit(25)
  end

  def licenses
    licenses = params[:term] ? License.autocomplete(params[:term]) : []
    render text: licenses.map { |l| { nice_name: l.nice_name, id: l.id.to_s } }.to_json
  end

  def contributions
    render json: @name_facts.map { |nf| nf.name.name }
  end

  def tags
    tags = Tag.autocomplete(params[:project_id], params[:term]).limit(10).pluck(:name)
    render json: tags
  end

  private

  def set_name_facts
    @name_facts = NameFact.where(analysis_id: @project.best_analysis_id)
                  .where(['lower(names.name) like ? ', "%#{params[:term].strip.downcase}%"])
                  .includes(:name).references(:all).order('names.name ASC').limit(10)
  end

  def check_for_project
    project_name = params[:project].to_s.strip.downcase
    @project = Project.active.where(['lower(name) = ?', project_name]).first unless project_name.empty?
    render text: '' if @project.nil? || @project.best_analysis_id.nil?
  end
end
