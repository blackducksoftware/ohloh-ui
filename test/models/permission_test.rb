require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  fixtures :projects, :organizations
  it 'default remainder for projects are for no restrictions' do
    permission = create(:permission, target: projects(:linux))
    permission.remainder.must_equal false
  end

  it 'default remainder for organizations are for no restrictions' do
    permission = create(:permission, target: organizations(:linux))
    permission.remainder.must_equal false
  end
end
