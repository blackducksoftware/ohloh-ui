class StackIgnoresController < ApplicationController
  before_action :session_required
  before_action :find_stack
  before_action :find_project, only: [:create]

  def create
    status = StackIgnore.create(stack_id: @stack.id, project_id: @project.id) ? :ok : :unprocessable_entity
    render json: { result: 'okay' }, status: status
  end

  def delete_all
    @stack.stack_ignores.destroy_all
    render nothing: true, status: :ok
  end

  private

  def find_stack
    @stack = Stack.find_by_id(params[:stack_id])
    fail ParamRecordNotFound if @stack.nil? || (@stack.account_id != current_user.id)
  end

  def find_project
    @project = Project.find_by_url_name(params[:stack_ignore][:project_id])
    fail ParamRecordNotFound if @project.nil?
  end
end
