# frozen_string_literal: true

require 'test_helper'

class ProjectShowTest < ActionDispatch::IntegrationTest
  let(:project) { create(:project) }

  describe 'Show' do
    before do
      login_as create(:account)
    end

    it 'should match for coverity scan URL' do
      project.update(coverity_project_id: Random.rand(100))
      get project_path(project.id)
      assert_response :success
      assert_match 'Coverity Scan', response.body
      assert_match project.coverity_scan_url, response.body
    end

    it 'should not match for coverity scan URL' do
      login_as create(:account)
      get project_path(project.id)
      assert_response :success
      assert_no_match 'Coverity Scan', response.body
      assert_no_match project.coverity_scan_url, response.body
    end
  end
end
