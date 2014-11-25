require 'test_helper'

class EditTest < ActiveSupport::TestCase
  def setup
    @edit = create(:create_edit)
    @previous_edit = create(:create_edit, value: '456', updated_at: Time.now - 5.days)
  end

  test "that we can get the previous_value of an edit" do
    assert '456', @edit.previous_value
  end

  test "that previous_value returns nil on initial edit" do
    assert nil, @previous_edit.previous_value
  end
end
