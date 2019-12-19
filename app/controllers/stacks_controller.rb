# frozen_string_literal: true

class StacksController < ApplicationController
  include RedirectIfDisabled
  helper MapHelper
  helper RatingsHelper, ProjectsHelper
  before_action :session_required, :redirect_unverified_account,
                except: %i[index show similar similar_stacks near project_stacks]
  before_action :find_stack, except: %i[index create near project_stacks]
  before_action :can_edit_stack, except: %i[index show create similar similar_stacks near project_stacks]
  before_action :find_account, :redirect_if_disabled, only: %i[index show similar]
  before_action :auto_ignore, only: [:builder]
  before_action :set_project_or_fail, only: %i[near project_stacks]
  before_action :account_context, only: %i[index show similar]
  before_action :verify_api_access_for_xml_request, only: [:project_stacks]

  def index
    @stacks = @account.stacks.paginate(page: page_param, per_page: 10)
  end

  def show
    @stack_entries = @stack.stack_entries.paginate(page: page_param, per_page: 10)
  end

  def create
    build_stack

    if @stack.save
      redirect_to stack_path(@stack)
    else
      redirect_to account_stacks_path(current_user), notice: t('.error')
    end
  end

  def update
    if @stack.update(model_params)
      render nothing: true, status: :ok
    else
      render text: ERB::Util.html_escape(@stack.errors.full_messages.to_sentence), status: :unprocessable_entity
    end
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

  def project_stacks; end

  private

  def build_stack
    @stack = Stack.new(model_params)
    @stack.account = current_user
    create_with_stack_entry? ? i_use_this : set_title
  end

  def set_title
    title = (1..30).collect { |i| "New Stack #{i}" } - Stack.where(account_id: @stack.account_id).map(&:title)
    @stack.title = title.first
  end

  def i_use_this
    set_project_or_fail
    stack_count = current_user.stacks.count + 1
    @stack.auto_generate_title_and_description(stack_count)
  end

  def model_params
    return {} unless params[:stack]

    params.require(:stack).permit(:title, :description, stack_entries_attributes: [:project_id])
  end

  def find_stack
    @stack = Stack.find_by(id: params[:id])
    raise ParamRecordNotFound if @stack.nil?
  end

  def can_edit_stack
    raise ParamRecordNotFound if @stack.account_id != current_user.id
  end

  def find_account
    @account = params[:account_id] ? Account.resolve_login(params[:account_id]) : @stack.account
    raise ParamRecordNotFound unless @account
  end

  def auto_ignore
    (params[:ignore] || []).split(',').compact.each do |project_vanity_url|
      proj = Project.find_by(vanity_url: project_vanity_url)
      StackIgnore.create(stack_id: @stack.id, project_id: proj.id) if proj
    end
  end

  def create_with_stack_entry?
    model_params.key?(:stack_entries_attributes)
  end
end
