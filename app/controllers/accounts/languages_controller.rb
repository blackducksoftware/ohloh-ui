class Accounts::LanguagesController < ApplicationController
  include SetAccountByAccountId
  helper :Projects

  before_action :account_context

  def index
    @contributions = @account.positions.includes(:contribution).map(&:contribution).group_by(&:project_id)
    return if @account.best_vita.nil?

    @vlfs = @account.best_vita.vita_language_facts.with_language_and_projects
    @logos_map = @account.best_vita.language_logos.index_by(&:id)
  end
end
