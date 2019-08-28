# frozen_string_literal: true

require 'test_helper'

class CompareProjectCsvDecoratorTest < ActionView::TestCase
  before do
    @project = create(:project)
    @decorator = CompareProjectCsvDecorator.new(@project, 'example.com')
  end

  describe 'unimplemented methods' do
    it 'should be delegated to the project' do
      @decorator.name.must_equal @project.name
    end
  end
end
