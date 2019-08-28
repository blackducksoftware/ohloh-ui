# frozen_string_literal: true

# Doorkeeper views do not have access to the rails application helpers.
# This is used to make the application layout render successfully for a doorkeeper view.
# Any new helper methods added for application layout will need to be added to this helper too.
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
    request.env[:clearance].current_user
  end

  def read_only_mode?
    false
  end

  def current_user_is_admin?
    Account::Access.new(current_user).admin?
  end
end
