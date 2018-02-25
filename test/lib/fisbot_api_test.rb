require 'test_helper'

describe 'FisbotApi' do
  it 'must raise error when the api throws an exception' do
    WebMocker.code_location_find_by_failure('some_branch')
    -> { CodeLocation.find_by(branch: 'some_branch') }.must_raise(StandardError)
  end
end
