class AutocompletesController < ApplicationController
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
end
