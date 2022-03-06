# frozen_string_literal: true

require 'test_helper'

class AffiliatedCommittersActivityTest < ActiveSupport::TestCase
  let(:org) { create(:organization) }
  let(:widget) { OrganizationWidget::AffiliatedCommittersActivity.new(organization_id: org.id) }

  describe 'position' do
    it 'should return 3' do
      _(widget.position).must_equal 3
    end
  end

  describe 'short_nice_name' do
    it 'should return shortened nice name' do
      default_nice_name = I18n.t('.organization_widgets.affiliated_committers_activity.short_nice_name')
      _(widget.short_nice_name).must_equal default_nice_name
    end
  end

  describe 'title' do
    it 'should return title' do
      _(widget.title).must_equal I18n.t('.organization_widgets.affiliated_committers_activity.title')
    end
  end
end
