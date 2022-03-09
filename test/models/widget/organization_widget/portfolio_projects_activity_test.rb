# frozen_string_literal: true

require 'test_helper'

class PortfolioProjectsActivityTest < ActiveSupport::TestCase
  let(:org) { create(:organization) }
  let(:widget) { OrganizationWidget::PortfolioProjectsActivity.new(organization_id: org.id) }

  describe 'title' do
    it 'should return title' do
      _(widget.title).must_equal I18n.t('organization_widgets.portfolio_projects_activity.title')
    end
  end

  describe 'short_nice_name' do
    it 'should return shortned name' do
      _(widget.short_nice_name).must_equal I18n.t('organization_widgets.portfolio_projects_activity.short_nice_name')
    end
  end

  describe 'position' do
    it 'should return 2' do
      _(widget.position).must_equal 2
    end
  end
end
