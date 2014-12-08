require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  fixtures :projects, :organizations
  test 'default remainder for projects are for no restrictions' do
    permission = create(:permission, target: projects(:linux))
    assert_equal false, permission.remainder
  end

  test 'default remainder for organizations are for no restrictions' do
    permission = create(:permission, target: organizations(:linux))
    assert_equal false, permission.remainder
  end
end
