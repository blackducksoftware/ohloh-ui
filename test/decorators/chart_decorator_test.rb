require 'test_helper'

describe 'ChartDecorator' do
  describe 'string_to_hash' do
    it 'must return year in number for january data' do
      ChartDecorator.new.string_to_hash(['Jan-2012']).must_equal [{ commit_month: 'Jan-2012', stringify: '2012' }]
    end

    it 'must return a blank stringify value for months other than january' do
      ChartDecorator.new.string_to_hash(['Feb-2012']).must_equal [{ commit_month: 'Feb-2012', stringify: '' }]
      ChartDecorator.new.string_to_hash(['Sep-2012']).must_equal [{ commit_month: 'Sep-2012', stringify: '' }]
      ChartDecorator.new.string_to_hash(['Nov-2012']).must_equal [{ commit_month: 'Nov-2012', stringify: '' }]
    end
  end
end
