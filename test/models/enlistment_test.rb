# frozen_string_literal: true

require 'test_helper'

class EnlistmentTest < ActiveSupport::TestCase
  let(:enlistment) { create_enlistment_with_code_location }
  let(:fyle) { create(:fyle) }

  describe 'ignore_examples' do
    it 'should be nil by default' do
      enlistment.stubs(:code_location).returns(code_location_stub)
      _(enlistment.ignore_examples).must_be_nil
    end

    it 'should return fyles' do
      code_location = code_location_stub
      code_location.stubs(:best_code_set).returns(fyle.code_set)
      enlistment.stubs(:code_location).returns(code_location)
      _(enlistment.ignore_examples.count).must_equal 1
      _(enlistment.ignore_examples.first).must_equal fyle.name
    end
  end

  describe 'Filtering Enlistments' do
    it 'should order and sort the result by last update' do
      Job.destroy_all
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      code_location_id = create_code_location_with_code_set_and_enlistment
      create(:failed_job, code_location_id: code_location_id, current_step_at: 1.month.ago)
      _(Enlistment.joins('join code_locations on code_location_id = code_locations.id
                        join repositories on code_locations.repository_id = repositories.id')
                  .by_last_update.count).must_equal 1
    end

    it 'should order based on the jobs.status and current_step_at' do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      cl1 = create_code_location_with_code_set_and_enlistment
      cl2 = create_code_location_with_code_set_and_enlistment
      cl3 = create_code_location_with_code_set_and_enlistment
      cl4 = create_code_location_with_code_set_and_enlistment
      Job.destroy_all
      create(:failed_job, code_location_id: cl4, current_step_at: 1.minute.ago)
      create(:sloc_job, code_location_id: cl3, current_step_at: 1.day.ago)
      create(:failed_job, code_location_id: cl2, current_step_at: 1.hour.ago)
      create(:fetch_job, code_location_id: cl1, current_step_at: 1.week.ago)
      _(Enlistment.by_update_status.pluck(:code_location_id)).must_equal [cl3, cl1, cl4, cl2].map(&:to_i)
    end
  end

  describe 'analysis_sloc_set' do
    it 'should return nil if best_analysis is nil' do
      _(enlistment.analysis_sloc_set).must_be_nil
    end

    it 'should return analysis_sloc_set' do
      enlistment = create(:enlistment)
      analysis_sloc_set = create(:analysis_sloc_set, analysis: enlistment.project.best_analysis)
      # TODO: Replace this once we remove code_locations table dependency from AnalysisSlocSet.
      Enlistment.connection.execute("insert into code_locations (best_code_set_id)
                                     values (#{analysis_sloc_set.sloc_set.code_set_id})")
      code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
      enlistment.update!(code_location_id: code_location_id)
      _(enlistment.analysis_sloc_set).must_equal analysis_sloc_set
    end
  end

  describe 'ensure_forge_and_job' do
    it 'should create a new job for project' do
      ApiAccess.stubs(:available?).returns(true)
      WebMocker.get_code_location
      CodeLocation.any_instance.stubs(:ensure_job).returns(false)
      Project.any_instance.stubs(:guess_forge)
      code_location = enlistment.code_location
      Project.any_instance.stubs(:code_locations).returns([code_location])

      analysis = create(:analysis, created_at: 2.months.ago)
      project = create(:project)
      project.update_column(:best_analysis_id, analysis.id)
      enlistment.update!(project_id: project.id)
      enlistment.unstub(:ensure_forge_and_job)
      enlistment.ensure_forge_and_job
      _(project.jobs.count).must_equal 1
    end
  end

  it 'must flag project for sync with KB when a enlistment is added' do
    assert_difference('KnowledgeBaseStatus.count', 1) do
      enlistment
    end
    _(KnowledgeBaseStatus.find_by(project_id: enlistment.project_id).in_sync).must_equal false
  end
end

# TODO: Replace this once we remove code_locations table dependency from enlistments_controller.
def create_code_location_with_code_set_and_enlistment
  code_set = create(:code_set)
  enlistment = create(:enlistment)
  url = Faker::Internet.url
  Enlistment.connection.execute("insert into repositories (type, url) values ('GitRepository', '#{url}')")
  repository_id = Enlistment.connection.execute('select max(id) from repositories').values[0][0]
  Enlistment.connection.execute("insert into code_locations (repository_id, best_code_set_id)
                                 values (#{repository_id}, #{code_set.id})")
  code_location_id = Enlistment.connection.execute('select max(id) from code_locations').values[0][0]
  code_set.update!(code_location_id: code_location_id)
  enlistment.update!(code_location_id: code_location_id)
  code_location_id
end
