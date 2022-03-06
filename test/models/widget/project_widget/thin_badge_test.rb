# frozen_string_literal: true

require 'test_helper'

class ThinBadgeTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::ThinBadge.new(project_id: project.id) }

  describe 'height' do
    it 'should return 32' do
      _(widget.height).must_equal 32
    end
  end

  describe 'width' do
    it 'should return 145' do
      _(widget.width).must_equal 145
    end
  end

  describe 'image' do
    it 'must call WidgetBadge::Thin.create' do
      WidgetBadge::Thin.expects(:create).once
      widget.image
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      _(widget.short_nice_name).must_equal I18n.t('project_widgets.thin_badge.short_nice_name')
    end
  end

  describe 'position' do
    it 'should return 10' do
      _(widget.position).must_equal 10
    end
  end
end
