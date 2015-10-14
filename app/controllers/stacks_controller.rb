class StacksController < ApplicationController
  include RedirectIfDisabled
  helper MapHelper
  helper RatingsHelper, ProjectsHelper

  before_action :session_required, :redirect_unverified_account,
                except: [:index, :show, :similar, :similar_stacks, :near, :project_stacks]
  before_action :find_stack, except: [:index, :create, :near, :project_stacks]
  before_action :can_edit_stack, except: [:index, :show, :create, :similar, :similar_stacks, :near, :project_stacks]
  before_action :find_account, :redirect_if_disabled, only: [:index, :show, :similar]
  before_action :auto_ignore, only: [:builder]
  before_action :set_project_or_fail, only: [:near, :project_stacks]
  before_action :account_context, only: [:index, :show, :similar]
  before_action :verify_api_access_for_xml_request, only: [:project_stacks]
  after_action :connect_stack_entry_to_stack, only: [:create], if: :request_is_xhr?

  def index
    @stacks = @account.stacks
  end

  def create
    create_stack
    if @stack.save
      respond_to do |format|
        format.html { redirect_to stack_path(@stack) }
        format.json { render json: { stack_url: stack_path(@stack) } }
      end
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

  def create_stack
    @stack = Stack.new
    @stack.account = current_user
    request_is_xhr? ? i_use_this : set_title
  end

  def set_title
    title = (1..30).collect { |i| "New Stack #{i}" } - Stack.where(account_id: @stack.account_id).pluck(:title)
    @stack.title = title.first
  end

  def i_use_this
    set_project_or_fail
    stack_count = current_user.stacks.count + 1
    @stack.auto_generate_title_and_description(stack_count)
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
    fail ParamRecordNotFound unless @account
  end

  def auto_ignore
    (params[:ignore] || []).split(',').compact.each do |project_url_name|
      proj = Project.find_by_url_name(project_url_name)
      StackIgnore.create(stack_id: @stack.id, project_id: proj.id) if proj
    end
  end

  def connect_stack_entry_to_stack
    StackEntry.create(stack_id: @stack.id, project_id: @project.id)
  end

  def request_is_xhr?
    request.xhr?
  end
end
