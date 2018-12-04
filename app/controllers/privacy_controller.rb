class PrivacyController < ApplicationController
  before_action :session_required, :redirect_unverified_account, only: %i[edit update]
  before_action :set_account
  before_action :update_email_opportunities_visited
  before_action :must_own_account, only: %i[edit update]
  before_action :set_oauth_applications

  def update
    if @account.update(account_params)
      redirect_to edit_account_privacy_account_path(@account), notice: t('.success')
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = if params[:id] == 'me'
                 return redirect_to new_session_path if current_user.nil?
                 current_user
               else
                 AccountFind.by_id_or_login(params[:id])
               end
    raise ParamRecordNotFound unless @account
  end

  def update_email_opportunities_visited
    # rubocop:disable Rails/SkipsModelValidations # We want to skip validations here.
    @account.update_attribute(:email_opportunities_visited, Time.current)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def set_oauth_applications
    @oauth_applications = Doorkeeper::Application
                          .joins(:access_tokens)
                          .where('oauth_access_tokens.resource_owner_id' => @account.id)
                          .where('oauth_access_tokens.revoked_at' => nil)
                          .uniq
  end

  def account_params
    params.require(:account).permit(:email_master, :email_kudos, :email_posts)
  end
end
