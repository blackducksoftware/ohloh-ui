class StacksController < ApplicationController
  helper MapHelper
  helper RatingsHelper

  before_action :session_required, except: [:index, :show, :similar, :similar_stacks, :near]
  before_action :find_stack, except: [:index, :create, :near]
  before_action :can_edit_stack, except: [:index, :show, :create, :similar, :similar_stacks, :near]
  before_action :find_account, only: [:index, :show, :similar]
  before_action :auto_ignore, only: [:builder]
  before_action :find_project, only: [:near]

  before_action :account_context, only: [:index, :show, :similar]

  def index
    @stacks = @account.stacks
  end

  def create
    @stack = Stack.new
    @stack.account = current_user
    set_title
    if @stack.save
      redirect_to stack_path(@stack)
    else
      redirect_to account_stacks_path(current_user), notice: t('.error')
    end
  end

  def update
    render nothing: true, status: (@stack.update_attributes(model_params) ? :ok : :unprocessable_entity)
  end

  def destroy
    account = @stack.account
    @stack.destroy
    redirect_to account_stacks_path(account), notice: t('.notice')
  end

  def reset
    @stack.stack_entries.destroy_all
    @stack.stack_ignores.destroy_all
    @stack.projects << Project.where(id: Stack::SAMPLE_PROJECT_IDS[params[:init].try(:to_sym)])
    redirect_to stack_path(@stack.id)
  end

  def similar
    @similar_stacks = @stack.similar_stacks
  end

  def similar_stacks
    render partial: 'similar_stacks', locals: { stack: @stack }
  end

  def builder
    @recommendations = render_to_string(partial: 'small_suggestion.html.haml', collection: @stack.suggest_projects(5))
    render json: { recommendations: @recommendations }
  end

  def near
    render text: view_context.map_near_stacks_json(@project, params)
  end

  private

  def set_title
    title = (1..30).collect { |i| "New Stack #{i}" } - Stack.where(account_id: @stack.account_id).pluck(:title)
    @stack.title = title.first
  end

  def model_params
    params.require(:stack).permit([:title, :description])
  end

  def find_stack
    @stack = Stack.find_by_id(params[:id])
    fail ParamRecordNotFound if @stack.nil?
  end

  def can_edit_stack
    fail ParamRecordNotFound if (@stack.account_id != current_user.id)
  end

  def find_account
    @account = params[:account_id] ? Account.resolve_login(params[:account_id]) : @stack.account
    fail ParamRecordNotFound unless @account && Account::Access.new(@account).active_and_not_disabled?
  end

  def auto_ignore
    (params[:ignore] || []).split(',').compact.each do |project_url_name|
      proj = Project.find_by_url_name(project_url_name)
      StackIgnore.create(stack_id: @stack.id, project_id: proj.id) if proj
    end
  end

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound unless @project
  end
end
