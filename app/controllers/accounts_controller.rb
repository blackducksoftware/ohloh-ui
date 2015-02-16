class AccountsController < ApplicationController
  before_action :account, only: [:show, :commits_by_project_chart, :commits_by_language_chart,
                                 :make_spammer, :activate]
  before_action :redirect_if_disabled, only: [:show, :commits_by_project_chart, :commits_by_language_chart]
  before_action :check_activation, only: [:activate]

  def index
    @people = Person.find_claimed(page: params[:page])
    @cbp_map = PeopleDecorator.new(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
    @twitter_detail = TwitterDetail.new(@account)
  end

  # NOTE: Replaces commits_history
  def commits_by_project_chart
    render json: Chart.new(@account).commits_by_project
  end

  # NOTE: Replaces language_experience
  def commits_by_language_chart
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end

  def languages
    @contributions = @account.positions.map(&:contribution).group_by(&:project_id)
    return if @account.best_vita.nil?
    @vlfs = @account.best_vita.vita_language_facts.with_languages_and_commits
    @logos_map = VitaLanguageFact.logos.index_by(&:id)
  end

  def bubble
    @kudo = Kudo.where(sender_id: current_account.id, account_id: @account.id).first if current_account
    render partial: 'bubble'
  end

  def delete_feedback
    return unless params[:reasons].present?
    reasons = params[:reasons].join(',')
    @deleted_account.update_attributes(reasons: "{#{reasons}}", reason_other: params[:reason_other].strip_tags)
    redirect_to message_path, success: I18n.t('delete_feedback.success')
  end

  def make_spammer
    @account.make_spammer!
    flash[:success] = I18n.t('make_spammer.success', name: CGI.escapeHTML(account.name))
    redirect_to account_path(account)
  end

  def activate
    @account.run_actions(Action::Status[:after_activation])
    session[:account] = @account.id
    redirect_to account_url(@account), success: I18n.t('activate.success')
  end

  def search
    if request.xhr?
      accounts = Account.simple_search(params[:term])
      render json: accounts.map(&:decorate).map(&:search_result)
    else
      redirect_to people_path(q: params[:term])
    end
  end

  # specific for autocomplete helper
  def autocomplete
    accounts = Account.simple_search(params[:term])
    render json: accounts.map(&:decorate).map(&:autocomplete_result)
  end

  def near
    accounts =
    if params[:zoom].to_i > 3
      Account.near(params[:lat].to_f, params[:lng].to_f)
    else
      Account.near_when_zoomed_out
    end
    render json: accounts
  end

  def resolve_login
    q = params[:q].to_s
    account = Account.resolve_login(params[:q])
    render json: account ? account.attributes.merge(q: q) : { id: nil, q: q }
  end

  def unsubscribe_emails
    account_id = Ohloh::Cipher.decrypt(CGI.escape(params[:key]))
    @account = Account.where(id: account_id).first
    @status = @account.try(:email_master)
    @account.update_attribute(:email_master, false) if @status
  end

  private

  def account
    accounts = Account.arel_table
    @account = Account.where(accounts[:id].eq(params[:id]).or(accounts[:login].eq(params[:id]))).first
  end

  def redirect_if_disabled
    redirect_to disabled_account_url(@account) if @account && Account::Access.new(@account).disabled?
  end

  def check_activation
    if @account.activated?
      redirect_to account_path(@account), notice: I18n.t('activate.notice')
    elsif @account.activate!(params[:code])
      redirect_to account_path(@account), notice: I18n.t('activate.no_code')
    end
  end
end
