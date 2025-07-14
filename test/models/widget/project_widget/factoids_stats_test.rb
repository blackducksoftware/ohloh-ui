# frozen_string_literal: true

require 'test_helper'

class FactoidsStatsTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { Widget::ProjectWidget::FactoidsStats.new(project_id: project.id) }

  describe 'height' do
    it 'should return 220' do
      _(widget.height).must_equal 220
    end
  end

  describe 'width' do
    it 'should return 370' do
      _(widget.width).must_equal 370
    end
  end

  describe 'title' do
    it 'should return the title' do
      _(widget.title).must_equal I18n.t('project_widgets.factoids_stats.title')
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      _(widget.short_nice_name).must_equal I18n.t('project_widgets.factoids_stats.short_nice_name')
    end
  end

  describe 'position' do
    it 'should return 1' do
      _(widget.position).must_equal 1
    end
  end
end
