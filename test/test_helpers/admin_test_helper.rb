# frozen_string_literal: true

module AdminTestHelper
  def create_and_login_admin
    admin = create(:admin, password: ActiveSupport::TestCase::TEST_PASSWORD)
    login_as admin
  end
end
