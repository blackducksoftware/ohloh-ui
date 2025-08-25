# frozen_string_literal: true

require 'test_helper'

class ProjectWidgetTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { Widget::ProjectWidget.new(project_id: project.id) }

  describe 'project' do
    it 'should return the project' do
      _(widget.project).must_equal project
    end
  end

  describe 'title' do
    it 'should return the project' do
      _(widget.title).must_equal I18n.t('project_widgets.title')
    end
  end

  describe 'border' do
    it 'should return zero' do
      _(widget.border).must_equal 0
    end
  end

  describe 'width' do
    it 'should return 380' do
      _(widget.width).must_equal 380
    end
  end

  describe 'initialize' do
    it 'should raise error for missing id' do
      _(proc { Widget::ProjectWidget.new }).must_raise ArgumentError
    end
  end

  describe 'create_widgets' do
    it 'should raise error for missing id' do
      widgets_classes = [
        Widget::ProjectWidget::FactoidsStats, Widget::ProjectWidget::Factoids, Widget::ProjectWidget::BasicStats,
        Widget::ProjectWidget::Languages, Widget::ProjectWidget::Cocomo,
        Widget::ProjectWidget::PartnerBadge, Widget::ProjectWidget::ThinBadge, Widget::ProjectWidget::UsersLogo
      ] + ([Widget::ProjectWidget::Users] * 6)
      _(Widget::ProjectWidget.create_widgets(project.id).map(&:class)).must_equal widgets_classes
    end
  end
end
