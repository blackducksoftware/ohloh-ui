class StacksController < ApplicationController
  helper MapHelper
  helper RatingsHelper

  before_action :session_required, except: [:index, :show, :similar, :near]
  before_action :find_stack, except: [:index, :create, :near]
  before_action :can_edit_stack, except: [:index, :show, :create, :similar, :near]
  before_action :find_account, only: [:index, :show]
  before_action :auto_ignore, only: [:builder]
  before_action :find_project, only: [:near, :create]
  before_action :account_context, only: [:index]
  after_action :connect_stack_entry_to_stack, only: [:create]

  def index
    @stacks = @account.stacks
  end

  def create
    create_stack
    if @stack.save
      respond_to do |format|
        format.html { redirect_to stack_path(@stack) }
        format.js { render action: 'i_use_this.js.erb' }
      end
    else
      redirect_to account_stacks_path(current_user), notice: t('.error')
    end
  end

  def update
    render nothing: true, status: (@stack.update_attributes(model_params) ? :ok : :unprocessable_entity)
  end

  def destroy
    render nothing: true, status: (@stack.destroy ? :ok : :unprocessable_entity)
  end

  def similar
    @similar_stacks = @stack.similar_stacks
  end

  def builder
    @recommendations = render_to_string(partial: 'small_suggestion.html.haml', collection: @stack.suggest_projects(5))
    render json: { recommendations: @recommendations }
  end

  def near
    render text: view_context.map_near_stacks_json(@project, params)
  end

  private

  def create_stack
    @stack = Stack.new
    @stack.account = current_user
    i_use_this if request.xhr?
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

  def i_use_this
    stack_count = current_user.stacks.count + 1
    @stack.auto_generate_title_and_description(stack_count)
  end

  def connect_stack_entry_to_stack
    StackEntry.create(stack_id: @stack.id, project_id: @project.id)
  end

  def i_use_this?
    request.xhr?
  end
end
