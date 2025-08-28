# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :find_account
  before_action :find_models, only: :index
  before_action :find_model, only: %i[edit update destroy]
  before_action :check_api_key_limit, only: %i[new create]
  before_action :must_be_key_owner
  before_action :account_context, only: %i[index new edit create update]

  API_KEYS_PER_PAGE = 10

  def index
    if request_format == 'csv'
      response.content_type = 'text/csv'
      response.headers['Content-Disposition'] = 'attachment; filename="api_keys_report.csv"'
    end
    render_with_format @account ? action_name : 'admin_index'
  end

  def new
    return render_404 unless @account

    @api_key = ApiKey.new
    render_with_format action_name
  end

  def edit
    return render_404 unless @account

    render_with_format action_name
  end

  def create
    return render_404 unless @account

    @api_key = ApiKey.new(model_params)
    @api_key.account = @account
    if @api_key.save
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      render :new, status: :bad_request
    end
  end

  def update
    return render_404 unless @account

    @api_key.account = @account
    if @api_key.update(model_params)
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      render :edit, status: :bad_request
    end
  end

  def destroy
    if @api_key.destroy
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      redirect_to account_api_keys_path(@account), notice: t('.error')
    end
  end

  private

  def find_account
    @account = params[:account_id] || params[:id] ? Account.from_param(params[:account_id]).take : nil
  end

  def model_params
    editable_params = [:name, :description, :url, :terms,
                       { oauth_application_attributes: %i[id name redirect_uri] }]
    editable_params << :daily_limit if current_user_is_admin?
    params.require(:api_key).permit(editable_params)
  end

  def find_model
    @api_key = ApiKey.find params[:id]
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def find_models
    @api_keys = (@account ? @account.api_keys : ApiKey)
                .joins(:account, :oauth_application)
                .includes(:account, :oauth_application).references(:all)
                .send(parse_sort_term)
                .filter_by(params[:query])
                .page(page_param)
                .limit(default_or_csv_limit)
  end

  def parse_sort_term
    ApiKey.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : 'by_newest'
  end

  def default_or_csv_limit
    request_format == 'csv' ? 2_147_483_648 : API_KEYS_PER_PAGE
  end

  def must_be_key_owner
    return unless (@account != current_user) && !current_user_is_admin?

    error(message: t(:not_authorized), status: :unauthorized)
  end

  def check_api_key_limit
    return unless @account.api_keys.size >= ApiKey::KEY_LIMIT_PER_ACCOUNT

    redirect_to account_api_keys_path(@account), notice: t('.limit_reached')
  end
end
