# frozen_string_literal: true

require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  it 'default remainder for projects are for no restrictions' do
    permission = create(:permission, target: create(:project))
    _(permission.remainder).must_equal false
  end

  it 'default remainder for organizations are for no restrictions' do
    permission = create(:permission, target: create(:organization))
    _(permission.remainder).must_equal false
  end
end
