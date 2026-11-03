# frozen_string_literal: true

module AdminTestHelper
  def create_and_login_admin
    password = PasswordGenerator.generate
    admin = create(:admin, password: password)
    login_as admin
  end
end
