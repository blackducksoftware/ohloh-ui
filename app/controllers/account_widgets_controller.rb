# frozen_string_literal: true

class AccountWidgetsController < WidgetsController
  before_action :set_account
  before_action :render_image_for_gif_format
  before_action :account_context, only: :index

  def index
    @widgets = Widget::AccountWidget.create_widgets(params[:account_id])
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).first!
  end
end
