# frozen_string_literal: true

class Accounts::LanguagesController < ApplicationController
  include SetAccountByAccountId
  helper :Projects

  before_action :account_context

  def index
    @contributions = @account.positions.includes(:contribution).map(&:contribution).compact.group_by(&:project_id)
    return if @account.best_account_analysis.nil?

    @vlfs = @account.best_account_analysis.account_analysis_language_facts.with_language_and_projects
    @logos_map = @account.best_account_analysis.language_logos.index_by(&:id)
  end
end
