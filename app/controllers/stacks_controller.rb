class StacksController < ApplicationController
  before_action :session_required, except: [:index, :show]
  before_action :find_stack, except: [:index, :create]
  before_action :can_edit_stack, except: [:index, :show, :create]
  before_action :find_account, only: [:index]

  def index
    @stacks = @account.stacks
  end

  def show
  end

  def create
    @stack = Stack.new
    @stack.account = current_user
    if @stack.save
      redirect_to stack_path(@stack)
    else
      redirect_to account_stacks_path(current_user), notice: t('.error')
    end
  end

  def update
    redirect_to stack_path(@stack), notice: (@stack.update_attibutes(model_params) ? t('.success') : t('.error'))
  end

  def destroy
    redirect_to stack_path(@stack), notice: (@stack.destroy ? t('.success') : t('.error'))
  end

  private

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
    @account = Account.resolve_login(params[:account_id])
    fail ParamRecordNotFound unless @account && Account::Access.new(@account).active_and_not_disabled?
  end
end
