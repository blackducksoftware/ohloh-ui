class ApiKeysController < ApplicationController
  #before_action :session_required
  before_action :find_account
  before_action :find_models, only: :index
  before_action :find_model, only: [:edit, :update, :destroy]
  before_filter :check_api_key_limit, only: [:new, :create]
  #before_filter :must_be_key_owner

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
    @model = ApiKey.new
    render_with_format action_name
  end

  def create
    return render_404 unless @account
    @model = ApiKey.new(model_params)
    @model.account = @account
    if @model.save
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      render :new, status: :bad_request
    end
  end

  def edit
    return render_404 unless @account
    render_with_format action_name
  end

  def update
    return render_404 unless @account
    @model.account = @account
    if @model.update(model_params)
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      render :edit, status: :bad_request
    end
  end

  def destroy
    if @model.destroy
      redirect_to account_api_keys_path(@account), notice: t('.success')
    else
      redirect_to account_api_keys_path(@account), notice: t('.error')
    end
  end

  private

  def find_account
    @account = params[:account_id] ? Account.find(params[:account_id]) : nil
  end

  def model_params
    editable_params = [:name, :description, :url, :terms]
    editable_params << :daily_limit if current_user_is_admin?
    params.require(:api_key).permit(editable_params)
  end

  def find_model
    @model = ApiKey.find params[:id]
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  rescue e
    raise e
  end

  def find_models
    find_query_param
    find_sort_param
    models = ApiKey.send(@sort).page(params[:page])
    models = models.limit((request_format == 'csv') ? 2_147_483_648 : API_KEYS_PER_PAGE)
    models = models.filterable_by(@query_term) if @query_term
    models = models.where(account_id: @account.id) if @account
    @models = models.to_a
  end

  def find_query_param
    @query_term = params[:q] || params[:query]
  end

  def find_sort_param
    @sort_options = { 'by_most_recent_request' => t('.sort_by_most_recent_request'),
                      'by_most_requests_today' => t('.sort_by_most_requests_today'),
                      'by_most_requests' => t('.sort_by_most_requests'),
                      'by_account_name' => t('.sort_by_account_name'),
                      'by_newest' => t('.sort_by_newest'),
                      'by_oldest' => t('.sort_by_oldest') }
    @sort = "by_#{params[:sort]}"
    @sort = 'by_newest' unless @sort_options.key?(@sort)
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
