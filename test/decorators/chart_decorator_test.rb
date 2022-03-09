# frozen_string_literal: true

require 'test_helper'

class ChartDecoratorTest < ActiveSupport::TestCase
  describe 'string_to_hash' do
    it 'must return year in number for january data' do
      _(ChartDecorator.new.string_to_hash(['Jan-2012'])).must_equal [{ commit_month: 'Jan-2012', stringify: '2012' }]
    end

    it 'must return a blank stringify value for months other than january' do
      _(ChartDecorator.new.string_to_hash(['Feb-2012'])).must_equal [{ commit_month: 'Feb-2012', stringify: '' }]
      _(ChartDecorator.new.string_to_hash(['Sep-2012'])).must_equal [{ commit_month: 'Sep-2012', stringify: '' }]
      _(ChartDecorator.new.string_to_hash(['Nov-2012'])).must_equal [{ commit_month: 'Nov-2012', stringify: '' }]
    end
  end

  describe 'background_style' do
    it 'must apply the passed argument to the parsed yaml content' do
      image_name = 'watermark_white_900'

      data = ChartDecorator.new.background_style(image_name)
      _(data['chart']['style']['background-image']).must_match(/#{image_name}.+png\)$/)
    end
  end

  describe 'project_commit_history' do
    it 'must build the chart data successfully' do
      account = create(:account)
      project = create(:project)
      CommitsByProject.any_instance.stubs(:chart_data).returns(x_axis: ['Jan-2012'], y_axis: 0, max_commits: 5)

      json_data = ChartDecorator.new.project_commit_history(account, project.id)
      data = JSON.parse(json_data)

      _(data['yAxis']['max']).must_equal 5
      _(data['xAxis']['categories']).must_equal [{ 'commit_month' => 'Jan-2012', 'stringify' => '2012' }]
    end
  end
end
