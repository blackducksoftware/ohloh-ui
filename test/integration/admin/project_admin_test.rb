require 'test_helper'

class ProjectAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:project) { create(:project) }

  before do
    login_as admin
  end

  it 'should render index page' do
    create(:project)

    get admin_projects_path
    assert_response :success
  end

  it 'should render show page' do
    get admin_project_path(create(:project))
    assert_response :success
  end

  it 'must render the edit page' do
    get edit_admin_project_path(create(:project).to_param)
    assert_response :success
  end

  describe 'create_analyze_job' do
    it 'must mark incomplete AnalyzeJob as failed and create new' do
      job = AnalyzeJob.create!(project_id: project.id)
      Job.find(job).wont_be :failed?

      assert_difference 'AnalyzeJob.count' do
        get create_analyze_job_admin_project_path(project.id)
      end

      Job.find(job).must_be :failed?
      flash[:success].wont_be :empty?
    end
  end
end
