# frozen_string_literal: true

class AutocompletesController < ApplicationController
  before_action :check_for_project, only: :contributions
  before_action :set_name_facts, only: :contributions
  before_action :set_projects_to_ignore, only: :projects_for_stack

  def account
    accounts = params[:term].blank? ? [] : Account.simple_search(params[:term])
    render json: accounts.map { |a| { login: a.login, name: a.name, value: a.login, id: a.id } }
  end

  def project
    @projects = Project.not_deleted
                       .where('lower(name) like ?', "%#{(params[:term] || '').downcase}%")
                       .where.not(id: params[:exclude_project_id].to_i)
                       .order('length(name)')
                       .limit(25)
  end

  def projects_for_stack
    @projects = Project.not_deleted
                       .where.not(id: @projects_to_ignore)
                       .where('lower(name) like ?', "%#{(params[:term] || '').downcase}%")
                       .order('length(name)')
                       .limit(25)
    render json: @projects.map { |p| { value: p.name, id: p.id } }
  end

  def project_duplicates
    @projects = Project.not_deleted.where('lower(name) like ?', "%#{params[:term].to_s.downcase}%").by_users.limit(25)
    render :project
  end

  def licenses
    licenses = params[:term] ? License.autocomplete(params[:term]) : []
    render plain: licenses.map { |l| { name: l.name, id: l.id.to_s } }.to_json
  end

  def contributions
    render json: @name_facts.map { |nf| nf.name.name }
  end

  def tags
    tags = Tag.select(:name).autocomplete(params[:project_id], params[:term]).limit(10).map(&:name)
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
    render plain: '' if @project.nil? || @project.best_analysis_id.nil?
  end

  def set_projects_to_ignore
    @projects_to_ignore = Stack.joins(:projects)
                               .where(account_id: params[:account_id], id: params[:id])
                               .pluck(Arel.sql('DISTINCT(projects.id)'))
  end
end
