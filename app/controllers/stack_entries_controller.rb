class StackEntriesController < ApplicationController
  helper RatingsHelper
  helper StacksHelper

  before_action :session_required, :redirect_unverified_account
  before_action :find_stack, except: :new
  before_action :find_project, only: [:create]
  before_action :find_stack_entry, except: %i[create new]
  before_action :set_project_or_fail, only: :new

  def new; end

  def create
    existing_entry = StackEntry.where(stack_id: @stack.id, project_id: @project.id, deleted_at: nil).first
    entry = existing_entry || StackEntry.create!(stack_id: @stack.id, project_id: @project.id, deleted_at: nil)
    render json: { stack_entry_id: entry.id, stack_entry: stack_entry_html(entry),
                   result: 'okay', updated_count: @stack.projects.count,
                   newly_added: existing_entry.nil? }, status: :ok
  rescue StandardError
    render json: { result: 'error' }, status: :unprocessable_entity
  end

  def update
    if params[:stack_entry] && @stack_entry.update(note: params[:stack_entry][:note])
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
    @stack = Stack.find_by(id: params[:stack_id])
    raise ParamRecordNotFound if @stack.nil? || ((@stack.account_id != current_user.id) && (params[:action] != 'show'))
  end

  def find_project
    se_params = params[:stack_entry]
    @project = find_project_by_vanity_url(se_params[:project_id]) || find_project_by_name(se_params[:project_name])
    raise ParamRecordNotFound if @project.nil?
  end

  def find_project_by_vanity_url(vanity_url)
    Project.find_by(vanity_url: vanity_url) if vanity_url
  end

  def find_project_by_name(name)
    Project.find_by(name: name) if name
  end

  def find_stack_entry
    @stack_entry = StackEntry.find_by(id: params[:id])
    raise ParamRecordNotFound if @stack_entry.nil?
  end

  def stack_entry_html(stack_entry)
    locals = { stack_entry: stack_entry, hidden: true, editable: true }
    render_to_string partial: 'stacks/stack_entry.html.haml', locals: locals
  end
end
