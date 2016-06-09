require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  it 'should read a key value when a valid key is provided' do
    key = 'hello'
    value = 'there'
    Setting.create(key: key, value: value)
    Setting.get_value(key).must_equal value
  end

  it 'should return nil when a invalid key is provided' do
    Setting.get_value('invalid_key').must_equal nil
  end
end
