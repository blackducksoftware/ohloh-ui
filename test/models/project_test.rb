require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:account) { create(:account) }
  let(:language) { create(:language) }
  let(:forge) { Forge.find_by(name: 'Github') }

  describe 'validations' do
    it 'should not allow project url_names to start with an underscore as we use those for routing' do
      build(:project, url_name: '_foobar').valid?.must_equal false
    end
  end

  describe 'hot' do
    it 'should return hot projects' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot.to_a.map(&:id).include?(proj.id).must_equal true
    end

    it 'should return hot projects with matching languages' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: language.id)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot(language.id).to_a.map(&:id).include?(proj.id).must_equal true
    end

    it 'should not return hot projects without matching languages' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: language.id)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot(language.id - 1).to_a.map(&:id).include?(proj.id).must_equal false
    end
  end

  describe 'related_by_stacks' do
    it ' should return related projects' do
      project1 = create(:project)
      project2 = create(:project)
      project3 = create(:project)
      stack1 = create(:stack)
      stack2 = create(:stack)
      stack3 = create(:stack)
      create(:stack_entry, stack: stack1, project: project1)
      create(:stack_entry, stack: stack1, project: project2)
      create(:stack_entry, stack: stack1, project: project3)
      create(:stack_entry, stack: stack2, project: project1)
      create(:stack_entry, stack: stack2, project: project2)
      create(:stack_entry, stack: stack2, project: project3)
      create(:stack_entry, stack: stack3, project: project1)
      create(:stack_entry, stack: stack3, project: project2)
      create(:stack_entry, stack: stack3, project: project3)
      project1.related_by_stacks.to_a.map(&:id).sort.must_equal [project2.id, project3.id]
      project2.related_by_stacks.to_a.map(&:id).sort.must_equal [project1.id, project3.id]
      project3.related_by_stacks.to_a.map(&:id).sort.must_equal [project1.id, project2.id]
    end
  end

  describe 'related_by_tags' do
    it 'should return related projects' do
      project1 = create(:project)
      project2 = create(:project)
      project3 = create(:project)
      tag = create(:tag)
      create(:tagging, tag: tag, taggable: project1)
      create(:tagging, tag: tag, taggable: project2)
      create(:tagging, tag: tag, taggable: project3)
      project1.related_by_tags.to_a.map(&:id).sort.must_equal [project2.id, project3.id]
      project2.related_by_tags.to_a.map(&:id).sort.must_equal [project1.id, project3.id]
      project3.related_by_tags.to_a.map(&:id).sort.must_equal [project1.id, project2.id]
    end
  end

  describe 'main_language' do
    it 'should return the best ananlysis language' do
      project.main_language.must_equal project.best_analysis.main_language.name
    end
  end

  describe 'managed_by' do
    it 'should return all projects managed by an account' do
      create(:manage, account: account, target: project)
      Project.managed_by(account).must_equal [project]
    end
  end

  describe 'to_param' do
    it 'should return the url_name' do
      project.to_param.must_equal project.url_name
    end
  end

  describe 'active_managers' do
    it 'should return the active accounts managing the project' do
      create(:manage, account: account, target: project)
      project.active_managers.must_equal [account]
    end
  end

  describe 'allow_undo_to_nil?' do
    it 'should return true if key is :name' do
      project.allow_undo_to_nil?(:name).must_equal false
    end

    it 'should return false if key is not :name' do
      project.allow_undo_to_nil?(:test).must_equal true
    end
  end

  describe 'allow_redo?' do
    it 'should return true if key is :organization_id and organization_id is present' do
      project.stubs(:organization_id).returns(1)
      project.allow_redo?(:organization_id).must_equal false
    end

    it 'should return false if key is not :organization_id' do
      project.allow_redo?(:test).must_equal true
    end
  end

  describe 'url and download_url' do
    it 'should clean up url value' do
      proj = create(:project)
      proj.update_attributes(url: 'openhub.net/url_cleanup')
      proj.reload.url.must_equal 'http://openhub.net/url_cleanup'
    end

    it 'should clean up url value' do
      proj = create(:project)
      proj.update_attributes(download_url: 'openhub.net/download_url_cleanup')
      proj.reload.download_url.must_equal 'http://openhub.net/download_url_cleanup'
    end

    it 'should require url value is a valid url if present' do
      proj = create(:project)
      proj.update_attributes(url: 'I am a banana!')
      proj.errors.messages[:url].must_equal [I18n.t(:not_a_valid_url)]
    end

    it 'should require url value is a valid url if present' do
      proj = create(:project)
      proj.update_attributes(download_url: 'I am a banana!')
      proj.errors.messages[:download_url].must_equal [I18n.t(:not_a_valid_url)]
    end

    it 'should support undo of setting url value' do
      proj = create(:project)
      proj.update_attributes(url: 'http://openhub.net/url')
      proj = Project.find(proj.id)
      prop_edits = PropertyEdit.for_target(proj).where(key: :url).to_a
      prop_edits.length.must_equal 1
      prop_edits[0].key.must_equal 'url'
      prop_edits[0].value.must_equal 'http://openhub.net/url'
      prop_edits[0].undo!(create(:admin))
      proj.reload.url.must_equal nil
    end

    it 'should support undo of setting download_url value' do
      proj = create(:project)
      proj.update_attributes(download_url: 'http://openhub.net/download_url')
      proj = Project.find(proj.id)
      prop_edits = PropertyEdit.for_target(proj).where(key: :download_url).to_a
      prop_edits.length.must_equal 1
      prop_edits[0].key.must_equal 'download_url'
      prop_edits[0].value.must_equal 'http://openhub.net/download_url'
      prop_edits[0].undo!(create(:admin))
      proj.reload.download_url.must_equal nil
    end
  end

  describe 'code_published_in_code_search?' do
    it 'should return false' do
      koder_status = KodersStatus.create!(project_id: project.id, ohloh_code_ready: false)
      project.stubs(:koders_status).returns(koder_status)
      project.code_published_in_code_search?.must_equal false
    end

    it 'should return true' do
      koder_status = KodersStatus.create!(project_id: project.id, ohloh_code_ready: true)
      project.stubs(:koders_status).returns(koder_status)

      project.code_published_in_code_search?.must_equal true
    end
  end

  describe 'newest_contributions' do
    it 'should return the latest contributions to a project' do
      person = create(:person)
      contribution = person.contributions.first
      project = contribution.project

      project.newest_contributions.must_equal [contribution]
    end
  end

  describe 'top_contributions' do
    it 'should return the top contributions to a project' do
      person = create(:person)
      contribution = person.contributions.first
      project = contribution.project

      project.top_contributions.must_equal [contribution]
    end
  end

  describe 'tag_list=' do
    it 'should record property_edits to the database' do
      project = create(:project)
      PropertyEdit.where(key: 'tag_list', target: project).count.must_equal 0
      project.update_attributes(tag_list: 'aquatic beavers cavort down east')
      project.reload.tags.length.must_equal 5
      PropertyEdit.where(key: 'tag_list', target: project).count.must_equal 1
      project.editor_account = create(:account)
      project.update_attributes(tag_list: 'zany')
      project.reload.tags.length.must_equal 1
      PropertyEdit.where(key: 'tag_list', target: project).count.must_equal 2
    end
  end

  describe 'from_param' do
    it 'should match project url_name' do
      project = create(:project)
      Project.from_param(project.url_name).first.id.must_equal project.id
    end

    it 'should match project id as string' do
      project = create(:project)
      Project.from_param(project.id.to_s).first.id.must_equal project.id
    end

    it 'should match project id as integer' do
      project = create(:project)
      Project.from_param(project.id).first.id.must_equal project.id
    end

    it 'should not match deleted projects' do
      project = create(:project)
      Project.from_param(project.to_param).count.must_equal 1
      project.destroy
      Project.from_param(project.to_param).count.must_equal 0
    end

    it 'should match project url_name case insensitively' do
      project = create(:project, url_name: 'wOwZeRs')
      Project.from_param('WoWzErS').first.id.must_equal project.id
    end
  end

  describe 'with_pai_available' do
    it 'should return count of projects with activity_level_index more than 0' do
      create(:project, activity_level_index: 20)

      Project.with_pai_available.must_equal 1
    end
  end

  describe 'search_and_sort' do
    it 'should return sorted search results' do
      pro_1 = create(:project, name: 'test na1', user_count: 5)
      pro_2 = create(:project, name: 'test na2', user_count: 10)
      pro_3 = create(:project, name: 'test na3', user_count: 9)

      Project.search_and_sort('test', 'new', nil).must_equal [pro_3, pro_2, pro_1]
    end
  end

  describe 'update_organzation_project_count' do
    it 'should update its organizations projects_count' do
      org = create(:organization)
      org.reload.projects_count.must_equal 0
      create(:project, organization: org)
      org.reload.projects_count.must_equal 1
    end
  end

  describe 'ensure_job' do
    it 'should update analysis sloc set logged at date if out of date' do
      analysis = create(:analysis, created_at: 25.days.ago)
      project = create(:project)
      project.update_column(:best_analysis_id, analysis.id)
      sloc_set = create(:sloc_set, as_of: 1, logged_at: Date.today)
      code_set = create(:code_set, as_of: 1, best_sloc_set: sloc_set)
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1, analysis: analysis, sloc_set: sloc_set)
      repo = create(:repository, best_code_set: code_set)
      create(:enlistment, project: project, repository: repo)

      Repository.any_instance.stubs(:ensure_job).returns(false)

      project.ensure_job
      analysis_sloc_set.reload.logged_at.must_equal Date.today
    end

    it 'should update activity level index if analsyis is old' do
      Analysis.any_instance.stubs(:activity_level).returns(:new)
      analysis = create(:analysis, updated_on: 2.months.ago)
      project = create(:project)
      project.update_columns(best_analysis_id: analysis.id, activity_level_index: 40)

      project.activity_level_index.must_equal 40
      project.ensure_job
      project.reload.activity_level_index.must_equal 10
    end

    it 'should not create a new job if project is deleted' do
      project = create(:project, deleted: true)
      create_repositiory(project)

      project.ensure_job
      project.jobs.count.must_equal 0
    end

    it 'should not create a new job if project has no repositories' do
      project = create(:project)
      create_repositiory(project)
      project.repositories.delete_all

      project.ensure_job
      project.jobs.count.must_equal 0
    end

    it 'should not create a new job if project already has a job' do
      project = create(:project)
      create_repositiory(project)
      AnalyzeJob.create(project: project, wait_until: Time.now + 5.hours)

      project.ensure_job
      project.jobs.count.must_equal 1
    end

    it 'should create new analyze job if project has no analysis' do
      project = create(:project)
      project.update_column(:best_analysis_id, nil)
      create_repositiory(project)
      Repository.any_instance.stubs(:ensure_job).returns(false)

      project.jobs.count.must_equal 0
      project.ensure_job
      project.jobs.count.must_equal 1
    end

    it 'should create new analyze job if project analysis is old' do
      analysis = create(:analysis, created_at: 2.months.ago)
      project = create(:project)
      project.update_column(:best_analysis_id, analysis.id)
      create_repositiory(project)

      Repository.any_instance.stubs(:ensure_job).returns(false)

      project.jobs.count.must_equal 0
      project.ensure_job
      project.jobs.count.must_equal 1
    end
  end

  describe 'schedule_delayed_analysis' do
    it 'should not create a job if no repository is available for the project' do
      project = create(:project)

      project.schedule_delayed_analysis
      project.jobs.count.must_equal 0
    end

    it 'should schedule analysis if no existing jobs are found' do
      project = create(:project)
      create_repositiory(project)
      project.repositories.first.jobs.delete_all

      project.jobs.count.must_equal 0
      project.schedule_delayed_analysis
      project.jobs.count.must_equal 1
    end

    it 'should not schedule analysis if project repository has jobs are found' do
      project = create(:project)
      create_repositiory(project)
      project.repositories.first.jobs.delete_all
      FetchJob.create(repository_id: project.repositories.first.id)

      project.jobs.count.must_equal 0
      project.schedule_delayed_analysis
      project.jobs.count.must_equal 0
    end

    it 'should update existing job if present' do
      project = create(:project)
      create_repositiory(project)
      AnalyzeJob.create(project: project, wait_until: Time.now + 5.hours)

      project.jobs.count.must_equal 1
      project.schedule_delayed_analysis(2.hours)
      project.jobs.count.must_equal 1
    end
  end

  private

  def create_repositiory(project)
    repo = create(:repository, url: 'git://github.com/rails/rails.git', forge_id: forge.id,
                               owner_at_forge: 'rails', name_at_forge: 'rails')
    create(:enlistment, project: project, repository: repo)
  end
end
