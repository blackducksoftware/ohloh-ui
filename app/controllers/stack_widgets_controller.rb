# frozen_string_literal: true

class StackWidgetsController < WidgetsController
  before_action :set_widget
  before_action :set_stack_and_account
  before_action :render_not_supported_for_gif_format
  before_action :render_iframe_for_js_format
  before_action :account_context, only: :index

  def index; end

  private

  def set_widget
    @widget = StackWidget.new(permitted_params)
  end

  def set_stack_and_account
    @stack = Stack.where(id: params[:stack_id]).first!
    @account = @stack.account
  end
end
