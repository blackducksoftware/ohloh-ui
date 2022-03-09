# frozen_string_literal: true

require 'test_helper'

class OpenSourceActivityTest < ActiveSupport::TestCase
  let(:org) { create(:organization) }
  let(:widget) { OrganizationWidget::OpenSourceActivity.new(organization_id: org.id) }

  describe 'short_nice_name' do
    it 'should return shorntened class name' do
      _(widget.short_nice_name).must_equal I18n.t('organization_widgets.open_source_activity.short_nice_name')
    end
  end

  describe 'position' do
    it 'should return 1' do
      _(widget.position).must_equal 1
    end
  end
end
