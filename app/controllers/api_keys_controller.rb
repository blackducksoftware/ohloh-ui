class ApiKeysController < ApplicationController
  before_action :session_required
  before_action :admin_session_required, only: :csv_download
  before_action :find_account
  before_action :find_models, only: :index
  before_action :find_model, only: [:edit, :update, :destroy]
  before_filter :check_api_key_limit, only: [:new, :create]
  before_filter :must_be_key_owner

  API_KEYS_PER_PAGE = 10

  def index
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
      redirect_to @model, notice: t('.success')
    else
      render(nothing: true, status: :created, location: @model)
    end
  end

  def edit
    render_with_format action_name
  end

  def update
    if @model.update(model_params)
      redirect_to @model, notice: t('.success')
    else
      render_with_format('edit', status: :unprocessable_entity)
    end
  end

  def delete
    if @model.destroy
      redirect_to :back, notice: t('.success')
    else
      redirect_to :back, alert: t('.error')
    end
  end

  def csv_download
    # send_data(csv_str, :type => 'text/csv', :filename => 'api_keys_report.csv', :disposition => 'attachment')
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
    raise CustomException::ParamRecordNotFound
  rescue e
    raise e
  end

  def find_models
    find_query_param
    find_sort_param
    models = ApiKey.send(@sort).limit(API_KEYS_PER_PAGE).page(params[:page])
    models = models.filterable_by(@query_term) if @query_term
    models = models.where(account_id: @account.id) if @account
    @models = models.to_a
  end

  def find_query_param
    @query_term = params[:q] || params[:query]
  end

  def find_sort_param
    @sort_options = { by_most_recent_request: t('.sort_by_most_recent_request'),
                      by_most_requests_today: t('.sort_by_most_requests_today'),
                      by_most_requests: t('.sort_by_most_requests'),
                      by_account_name: t('.sort_by_account_name'),
                      by_newest: t('.sort_by_newest'),
                      by_oldest: t('.sort_by_oldest') }
    @sort = "by_#{params[:sort]}".to_sym
    @sort = :by_newest unless @sort_options.key?(@sort)
  end

  def must_be_key_owner
    return unless (@account != current_user) && !current_user_is_admin?
    error(message: t(:not_authorized), status: :unauthorized)
  end

  def check_api_key_limit
    return unless @account.api_keys.size >= ApiKey::KEY_LIMIT_PER_ACCOUNT
    redirect_to account_api_keys_path(current_account), notice: t('.limit_reached')
  end
end
