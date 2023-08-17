# frozen_string_literal: true

require 'test_helper'

class ProjectAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:project) { create(:project) }

  before do
    login_as admin
  end

  describe 'index' do
    it 'should render index page' do
      create(:project)

      get admin_projects_path
      assert_response :success
    end

    it 'must render index with projects having active enlistments' do
      project_with_enlistment = create(:enlistment).project
      plain_project = create(:project)

      get admin_projects_path, params: { q: { has_active_enlistments: true } }

      _(response.body).must_match project_with_enlistment.name
      _(response.body).wont_match plain_project.name
    end

    it 'must render index filtered by a range of best_analysis created time' do
      project1 = create(:project)
      create(:enlistment, project: project1)
      project2 = create(:project)
      create(:enlistment, project: project2)
      project3 = create(:project)

      project1.best_analysis.update! created_at: 4.days.ago
      project2.best_analysis.update! created_at: 3.days.ago

      date_range = { last_analyzed_gteq_datetime: 5.days.ago.to_date.to_s,
                     last_analyzed_lteq_datetime: 3.days.ago.to_date.to_s }
      get admin_projects_path, params: { q: date_range }

      _(response.body).must_match project1.name
      _(response.body).must_match project2.name
      _(response.body).wont_match project3.name
    end

    it 'must render index page ordered by last_analyzed' do
      project1 = create(:project)
      create(:enlistment, project: project1)
      project2 = create(:project)
      create(:enlistment, project: project2)

      project1.best_analysis.update! created_at: 1.day.since

      get admin_projects_path, params: { order: 'analyses.created_at_desc' }

      _(assigns(@projects)['projects'].map(&:id)).must_equal [project1.id, project2.id]
    end

    it 'should render index page with active projects' do
      create(:project)

      get admin_projects_path, params: { active: true }
      assert_response :success
    end
  end

  it 'should render show page' do
    get admin_project_path(create(:project))
    assert_response :success
  end

  describe 'scope validation' do
    it 'last_analyzed_gteq_datetime' do
      project.best_analysis.update! created_at: 1.day.ago
      date = 2.days.ago.to_date.to_s
      _(Project.last_analyzed_gteq_datetime(date).first.name).must_match project.name
    end

    it 'last_analyzed_lteq_datetime' do
      project.best_analysis.update! created_at: 3.days.ago
      date = 2.days.ago.to_date.to_s
      _(Project.last_analyzed_lteq_datetime(date).first.name).must_match project.name
    end
  end

  describe 'create_analyze_job' do
    it 'must mark incomplete ProjectAnalysisJob as failed and create new' do
      job = ProjectAnalysisJob.create!(project_id: project.id)
      _(Job.find(job.id)).wont_be :failed?

      assert_difference 'ProjectAnalysisJob.count' do
        get create_analyze_job_admin_project_path(project.id)
      end

      _(Job.find(job.id)).must_be :failed?
      _(flash[:success]).wont_be :empty?
      assert_equal job.reload.do_not_retry, true
    end
  end
end
