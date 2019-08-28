# frozen_string_literal: true

module Account::ClearanceUser
  extend ActiveSupport::Concern

  included do
    include Clearance::User

    def email_optional?
      true
    end
  end
end
