class StackWidgetsController < WidgetsController
  before_action :set_stack_and_widget
  before_action :render_not_supported_thin_badge
  before_action :render_for_js_format
  skip_before_action :set_widget

  def index
    @account = @stack.account
  end

  private

  def set_stack_and_widget
    @widget = StackWidget.new(stack_id: params[:stack_id])
    @stack = Stack.where(id: params[:stack_id]).first!
  end
end
