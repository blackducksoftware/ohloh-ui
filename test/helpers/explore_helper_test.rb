# frozen_string_literal: true

require 'test_helper'

class ExploreHelperTest < ActionView::TestCase
  include ExploreHelper

  describe 'scale_to' do
    it 'should return scaled value with two arguments' do
      _(scale_to(94)).must_equal 100
    end

    it 'should return scaled value with one argument' do
      _(scale_to(94, 1000)).must_equal 1000
    end
  end

  describe 'compare_project_inputs' do
    it 'should return an array of input hashes for compare projects' do
      stubs(:t).with('.enter_project').returns('Enter project')
      inputs = compare_project_inputs
      _(inputs.length).must_equal 3
      _(inputs.first[:name]).must_equal 'project_0'
      _(inputs.first[:type]).must_equal 'text'
      _(inputs.first[:id]).must_equal 'project_0'
      _(inputs.last[:name]).must_equal 'project_2'
    end
  end

  describe 'cache_projects_explore_page' do
    it 'should call render with projects when language is present' do
      @language = create(:language)
      expects(:render).with('projects').returns('<html>projects</html>')
      result = cache_projects_explore_page
      _(result).must_equal '<html>projects</html>'
    end

    it 'should use cache when language is blank' do
      @language = nil
      Rails.cache.clear
      expects(:render).with('projects').returns('<html>cached</html>')
      result = cache_projects_explore_page
      _(result).must_equal '<html>cached</html>'
    end
  end
end
