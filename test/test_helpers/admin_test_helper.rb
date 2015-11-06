module AdminTestHelper
  def create_and_login_admin
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
  end
end
