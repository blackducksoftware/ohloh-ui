class DeletedAccountsController < ApplicationController
  before_action :deleted_account?, only: :delete_feedback

  # NOTE: Replaces accounts#delete_feedback.
  def delete_feedback
    return if request.get? || params[:reasons].blank?
    processed_reasons = process_reason_params(params)
    @deleted_account.update(reasons: processed_reasons[:reasons], reason_other: processed_reasons[:other])
    redirect_to message_path, flash: { success: t('.success') }
  end

  private

  def process_reason_params(params)
    { reasons: "{#{params[:reasons].join(',')}}", other: String.clean_string(params[:reason_other]) }
  end

  def deleted_account?
    @deleted_account = DeletedAccount.find_deleted_account(params[:login])
    elapsed = @deleted_account.try(:feedback_time_elapsed?)
    account = Account.find_by_login(params[:login])
    return if account.nil? && @deleted_account && !elapsed
    redirect_to message_path, flash: { error: elapsed ? t('.expired') : t('.invalid_request') }
  end
end
