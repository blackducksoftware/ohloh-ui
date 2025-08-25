# frozen_string_literal: true

require 'test_helper'

class OrganizationWidgetTest < ActiveSupport::TestCase
  let(:org) { create(:organization) }
  let(:widget) { Widget::OrganizationWidget.new(organization_id: org.id) }

  describe 'title' do
    it 'should return title' do
      _(widget.title).must_equal I18n.t('organization_widgets.title')
    end
  end

  describe 'border' do
    it 'should return zero' do
      _(widget.border).must_equal 0
    end
  end

  describe 'organization' do
    it 'should return organization' do
      _(widget.organization).must_equal org
    end
  end

  describe 'height' do
    it 'should return 200' do
      _(widget.height).must_equal 200
    end
  end

  describe 'width' do
    it 'should return 328' do
      _(widget.width).must_equal 328
    end
  end

  describe 'create_widgets' do
    it 'should create descendan widgets' do
      widget_classes = [Widget::OrganizationWidget::OpenSourceActivity,
                        Widget::OrganizationWidget::PortfolioProjectsActivity,
                        Widget::OrganizationWidget::AffiliatedCommittersActivity]
      _(Widget::OrganizationWidget.create_widgets(org.id).map(&:class)).must_equal widget_classes
    end
  end

  describe 'initialize' do
    it 'should raise exception if account is missing' do
      _(proc { Widget::OrganizationWidget.new }).must_raise ArgumentError
    end
  end
end
