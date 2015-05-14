require 'test_helper'

class ToolHelperTest < ActionView::TestCase
  include ToolHelper

  let(:sidebar) do
    [
      [
        [nil, 'Tools'],
        [:compare_projects, 'Compare Projects', '/p/compare'],
        [:compare_languages, 'Compare Languages', '/languages/compare'],
        [:compare_repositories, 'Compare Repositories', '/repositories/compare']
      ],
      [
        [nil, 'Languages', nil, 'select'],
        ['select...', ''],
        ['All Languages', '/languages'],
        ['C', '/languages/c']
      ]
    ]
  end

  it 'should return two sections' do
    tools_sidebar.length.must_equal 2
  end

  it 'should return tools menu list' do
    tools_sidebar.must_equal sidebar
  end
end
