require 'test_helper'

class ToolHelperTest < ActionView::TestCase
  include ToolHelper

  let(:sidebar) do
    [
      [
        [nil, 'Tools'],
        [:compare_projects, 'Compare Projects', '/p/compare'],
        [:compare_languages, 'Compare Languages', '/languages/compare'],
        [:compare_repositories, 'Compare Repositories', '/compare_repositories']
      ],
      [
        [nil, 'Languages', nil, 'select'],
        ['All Languages', '/languages'],
        ['select...', ''],
        ['C', '/languages.1'],
        ['C++', '/languages.2'],
        ['Java', '/languages.3'],
        ['Javascript', '/languages.4'],
        ['Python', '/languages.5'],
        ['Ruby', '/languages.6']
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
