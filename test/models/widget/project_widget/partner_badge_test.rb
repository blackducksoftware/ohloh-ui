# frozen_string_literal: true

require 'test_helper'

class ProjectPartnerBadgeTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { Widget::ProjectWidget::PartnerBadge.new(project_id: project.id) }

  describe 'height' do
    it 'should return 50' do
      _(widget.height).must_equal 50
    end
  end

  describe 'width' do
    it 'should return 245' do
      _(widget.width).must_equal 245
    end
  end

  describe 'image' do
    it 'must call WidgetBadge::Partner.create' do
      WidgetBadge::Partner.expects(:create).once
      widget.image
    end
  end

  describe 'position' do
    it 'should return 9' do
      _(widget.position).must_equal 9
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      _(widget.short_nice_name).must_equal I18n.t('project_widgets.partner_badge.short_nice_name')
    end
  end
end
