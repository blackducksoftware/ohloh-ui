class StackEntriesController < ApplicationController
  before_action :session_required
  before_action :find_stack
  before_action :find_project
  before_action :find_stack_entry, only: [:destroy]

  def create
    status = StackEntry.create(stack_id: @stack.id, project_id: @project.id) ? :ok : :unprocessable_entity
    render json: { result: 'okay' }, status: status
  end

  def destroy
    render json: { result: 'okay' }, status: (@stack_entry.destroy ? :ok : :unprocessable_entity)
  end

  private

  def find_stack
    @stack = Stack.find_by_id(params[:stack_id])
    fail ParamRecordNotFound if @stack.nil? || (@stack.account_id != current_user.id)
  end

  def find_project
    @project = Project.find_by_url_name(params[:stack_entry][:project_id])
    fail ParamRecordNotFound if @project.nil?
  end

  def find_stack_entry
    @stack_entry = StackEntry.find_by_id(params[:id])
    fail ParamRecordNotFound if @stack_entry.nil?
  end
end
