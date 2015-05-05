module OauthLayoutHelper
  private
  mattr_reader :generate_page_name, :find_nag_reminder

  def page_context
    {}
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    Account.find_by(id: session[:account_id])
  end

  def read_only_mode?
    false
  end
end
