# frozen_string_literal: true

require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  it 'should show the last deployment details' do
    stubs(:get_revision_details).returns(['abc123', Date.yesterday])
    get_last_deployment.match('https://github.com/blackducksoftware/ohloh-ui/commit/abc123')
  end

  it 'must show details from the REVISION file' do
    commit_sha = ' e2s1sds3 '
    time = Faker::Time.backward
    fyle = stub(read: commit_sha, mtime: time, close: true)
    File.stubs(:open).returns(fyle)

    _(get_revision_details).must_equal [commit_sha.strip, time]
  end

  it 'must return active project count' do
    _(project_count).must_equal Project.active.count
  end

  it 'must return active enlistments project count' do
    _(active_projects_count).must_equal Project.active_enlistments.distinct.size
  end

  it 'days_projects_count returns N/A when active project count is zero' do
    stubs(:active_projects_count).returns(0)

    _(days_projects_count).must_equal 'N/A'
  end

  it 'days_projects_count returns percentage using cached value' do
    stubs(:active_projects_count).returns(100)
    Rails.cache.stubs(:fetch).with('Admin-updated-project-count-cache').returns(25)

    _(days_projects_count).must_equal number_to_percentage(25.0, precision: 2)
  end

  it 'weeks_projects_count returns percentage using cached value' do
    stubs(:active_projects_count).returns(200)
    Rails.cache.stubs(:fetch).with('Admin-weeks-updated-project-count-cache').returns(50)

    _(weeks_projects_count).must_equal number_to_percentage(25.0, precision: 2)
  end

  it 'outdated_projects defaults to zero when cache miss occurs' do
    stubs(:active_projects_count).returns(200)
    Rails.cache.stubs(:fetch).with('Admin-outdated-project-count-cache').returns(nil)

    _(outdated_projects).must_equal number_to_percentage(0.0, precision: 2)
  end

  it 'without_analysis_projects_count returns percentage from query count' do
    stubs(:active_projects_count).returns(200)

    active_scope = mock
    enlistment_scope = mock
    count_scope = mock

    Project.stubs(:active).returns(active_scope)
    active_scope.stubs(:where).returns(enlistment_scope)
    enlistment_scope.stubs(:where).with(best_analysis_id: nil).returns(count_scope)
    count_scope.stubs(:count).returns(50)

    _(without_analysis_projects_count).must_equal number_to_percentage(25.0, precision: 2)
  end
end
