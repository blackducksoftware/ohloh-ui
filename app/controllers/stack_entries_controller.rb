class StackEntriesController < ApplicationController
  helper RatingsHelper
  helper StacksHelper

  before_action :session_required, :redirect_unverified_account
  before_action :find_stack, except: :new
  before_action :find_project, only: [:create]
  before_action :find_stack_entry, except: [:create, :new]

  helper_method :display_as_project_page

  def new
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
    @stacks = current_user.stacks
    render partial: 'new'
  end

  def create
    stack_entry = StackEntry.where(stack_id: @stack.id, project_id: @project.id, deleted_at: nil).first_or_create!
    render json: { stack_entry_id: stack_entry.id,
                   stack_entry: stack_entry_html(stack_entry),
                   result: 'okay', updated_count: @stack.projects.count }, status: :ok
  rescue
    render json: { result: 'error' }, status: :unprocessable_entity
  end

  def update
    if params[:stack_entry] && @stack_entry.update_attributes(note: params[:stack_entry][:note])
      render json: { result: 'okay' }, status: :ok
    else
      render json: { result: 'error' }, status: :unprocessable_entity
    end
  end

  def destroy
    render json: { result: 'okay' }, status: (@stack_entry.destroy ? :ok : :unprocessable_entity)
  end

  private

  def find_stack
    @stack = Stack.find_by_id(params[:stack_id])
    fail ParamRecordNotFound if @stack.nil? || ((@stack.account_id != current_user.id) && (params[:action] != 'show'))
  end

  def find_project
    se_params = params[:stack_entry]
    @project = find_project_by_url_name(se_params[:project_id]) || find_project_by_name(se_params[:project_name])
    fail ParamRecordNotFound if @project.nil?
  end

  def find_project_by_url_name(url_name)
    Project.find_by_url_name(url_name) if url_name
  end

  def find_project_by_name(name)
    Project.find_by_name(name) if name
  end

  def find_stack_entry
    @stack_entry = StackEntry.find_by_id(params[:id])
    fail ParamRecordNotFound if @stack_entry.nil?
  end

  def stack_entry_html(stack_entry)
    locals = { stack_entry: stack_entry, hidden: true, editable: true }
    render_to_string partial: 'stacks/stack_entry.html.haml', locals: locals
  end

  def display_as_project_page
    params[:redirect] || params[:ref]
  end
end
