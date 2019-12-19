# frozen_string_literal: true

class Account::DisabledGuard < Clearance::SignInGuard
  def call
    return failure(I18n.t('accounts.disabled_error')) if current_user&.access&.disabled?

    next_guard
  end
end
