require 'test_helper'
require 'test_helpers/create_contributions_data'

class ProjectTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:account) { create(:account) }
  let(:language) { create(:language) }
  let(:forge) { Forge.find_by(name: 'Github') }

  describe 'validations' do
    it 'should not allow project vanity_urls to start with an underscore as we use those for routing' do
      build(:project, vanity_url: '_foobar').valid?.must_equal false
    end

    describe 'vanity_url' do
      it 'must allow valid characters' do
        valid_vanity_urls = %w(proj-name proj_name projéct proj_)

        valid_vanity_urls.each do |name|
          project = build(:project, vanity_url: name)
          project.wont_be :valid?
        end
      end

      it 'wont allow invalid characters' do
        invalid_vanity_urls = %w(proj.name .proj -proj _proj)

        invalid_vanity_urls.each do |name|
          project = build(:project, vanity_url: name)
          project.wont_be :valid?
        end
      end
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

    it 'should not return same project twice' do
      proj = create(:project, deleted: false)
      analysis1 = create(:analysis, project_id: proj.id, hotness_score: 999_999)
      create(:analysis, project_id: proj.id, hotness_score: 999_999)
      proj.update_attribute('best_analysis_id', analysis1.id)
      Project.hot.count.must_equal 1
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
    it 'should return the vanity_url' do
      project.to_param.must_equal project.vanity_url
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

    it 'should return false if key is vanity_url' do
      project.allow_undo_to_nil?(:vanity_url).must_equal false
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

    it 'should have project creation edit as the first edit' do
      account = create(:account, password: 'password', level: 10)
      proj = create(:project, editor_account: account, url: 'http://openhub.net', download_url: 'http://openhub.net/download')
      edits = proj.links.map(&:edits).flatten + proj.edits

      project_edits = edits.select { |e| e.target_type == 'Project' }
      link_edits = edits.select { |e| e.target_type == 'Link' }
      project_edits.wont_be_empty
      link_edits.wont_be_empty

      first_edit = edits.min_by(&:created_at)
      first_edit.type.must_equal 'CreateEdit'
      first_edit.target_type.must_equal 'Project'
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
      assert_nil proj.reload.url
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
      assert_nil proj.reload.download_url
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
    it 'should match project vanity_url' do
      project = create(:project)
      Project.from_param(project.vanity_url).first.id.must_equal project.id
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

    it 'should match project vanity_url case insensitively' do
      project = create(:project, vanity_url: 'wOwZeRs')
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
      project.update_column(:best_analysis_id, analysis.id)
      sloc_set = create(:sloc_set, as_of: 1)
      code_set = create(:code_set, as_of: 1, best_sloc_set: sloc_set)
      analysis_sloc_set = create(:analysis_sloc_set, as_of: 1, analysis: analysis, sloc_set: sloc_set)

      sloc_set.update!(code_set_time: Date.current)
      WebMocker.create_code_location(201, best_code_set_id: code_set.id)
      unmocked_create_enlistment_with_code_location(project, best_code_set_id: code_set.id)
      CodeLocation.any_instance.stubs(:ensure_job).returns(false)

      WebMocker.get_project_code_locations(true, best_code_set_id: code_set.id)
      project.ensure_job

      analysis_sloc_set.reload.code_set_time.must_equal Date.current
    end

    it 'should update activity level index if analsyis is old' do
      Analysis.any_instance.stubs(:activity_level).returns(:new)
      analysis = create(:analysis, updated_on: 2.months.ago)
      project = create(:project)
      project.update_columns(best_analysis_id: analysis.id, activity_level_index: 40)

      project.activity_level_index.must_equal 40
      project.stubs(:code_locations).returns([])
      project.ensure_job
      project.reload.activity_level_index.must_equal 10
    end

    it 'should not create a new job if project is deleted' do
      project = create(:project, deleted: true)
      project.stubs(:code_locations).returns([code_location_stub])

      project.ensure_job
      project.jobs.count.must_equal 0
    end

    it 'should not create a new job if project has no code_locations' do
      project = create(:project)
      project.stubs(:code_locations).returns([])

      project.ensure_job
      project.jobs.count.must_equal 0
    end

    it 'should not create a new job if project already has a job' do
      project = create(:project)
      project.stubs(:code_locations).returns([code_location_stub])
      AnalyzeJob.create(project: project, wait_until: Time.current + 5.hours)

      project.ensure_job
      project.jobs.count.must_equal 1
    end

    it 'should create new analyze job if project has no analysis' do
      project = create(:project)
      project.update_column(:best_analysis_id, nil)
      project.stubs(:code_locations).returns([code_location_stub])
      CodeLocation.any_instance.stubs(:ensure_job).returns(false)

      project.jobs.count.must_equal 0
      project.ensure_job
      project.jobs.count.must_equal 1
    end

    it 'should create new analyze job if project analysis is old' do
      analysis = create(:analysis, created_at: 2.months.ago)
      project = create(:project)
      project.update_column(:best_analysis_id, analysis.id)
      project.stubs(:code_locations).returns([code_location_stub])

      CodeLocation.any_instance.stubs(:ensure_job).returns(false)

      project.jobs.count.must_equal 0
      project.ensure_job
      project.jobs.count.must_equal 1
    end
  end

  describe 'schedule_delayed_analysis' do
    it 'should not create a job if no code_location is available for the project' do
      project = create(:project)
      project.stubs(:code_locations).returns([])

      project.schedule_delayed_analysis
      project.jobs.count.must_equal 0
    end

    it 'should schedule analysis if no existing jobs are found' do
      project = create(:project)
      project.stubs(:code_locations).returns([code_location_stub])

      project.jobs.count.must_equal 0
      project.schedule_delayed_analysis
      project.jobs.count.must_equal 1
    end

    it 'should not schedule analysis if project code_location has jobs are found' do
      project = create(:project)
      code_location = code_location_stub_with_id
      project.stubs(:code_locations).returns([code_location])
      FetchJob.create(code_location_id: code_location.id)

      project.jobs.count.must_equal 0
      project.schedule_delayed_analysis
      project.jobs.count.must_equal 0
    end

    it 'should update existing job if present' do
      project = create(:project)
      project.stubs(:code_locations).returns([code_location_stub])
      AnalyzeJob.create(project: project, wait_until: Time.current + 5.hours)

      project.jobs.count.must_equal 1
      project.schedule_delayed_analysis(2.hours)
      project.jobs.count.must_equal 1
    end
  end

  describe 'contributions_within_timespan' do
    it 'should return contributions within 30 days' do
      project = create(:project)
      created_contributions = create_contributions(project)
      contributions = project.contributions_within_timespan(time_span: '30 days')
      contributions.size.must_equal 2
      contributions.must_include created_contributions[0]
      contributions.must_include created_contributions[1]
    end

    it 'should return contributions within 12 months' do
      project = create(:project)
      created_contributions = create_contributions(project)
      contributions = project.contributions_within_timespan(time_span: '12 months')
      contributions.size.must_equal 3
      contributions.must_include created_contributions[0]
      contributions.must_include created_contributions[1]
      contributions.must_include created_contributions[2]
    end

    it 'should return all contributions' do
      project = create(:project)
      created_contributions = create_contributions(project)
      contributions = project.contributions_within_timespan({})
      contributions.size.must_equal 4
      contributions.must_include created_contributions[0]
      contributions.must_include created_contributions[1]
      contributions.must_include created_contributions[2]
      contributions.must_include created_contributions[3]
    end
  end

  describe 'stacks_count' do
    it 'should return user_count' do
      project = create(:project)
      create(:stack_entry, project: project)
      stack_entry1 = create(:stack_entry, project: project)
      stack_entry2 = create(:stack_entry, project: project)
      stack_entry1.stack.update_column(:account_id, stack_entry2.stack.account_id)
      project.stacks_count.must_equal 2
    end

    it 'should return user_count without taking into account disabled or spammer accounts' do
      project = create(:project)
      create(:stack_entry, project: project)
      create(:stack_entry, project: project)
      stack_entry1 = create(:stack_entry, project: project)
      stack_entry2 = create(:stack_entry, project: project)

      stack_entry1.stack.account.update_column(:level, -10)
      stack_entry2.stack.account.update_column(:level, -20)

      project.stacks_count.must_equal 2
    end
  end

  describe 'users' do
    it 'should return users that are not spam or disabled' do
      project = create(:project)
      stack_entry = create(:stack_entry, project: project)
      stack_entry1 = create(:stack_entry, project: project)
      stack_entry2 = create(:stack_entry, project: project)
      stack_entry3 = create(:stack_entry, project: project)
      stack_entry1.stack.account.update_column(:level, -10)
      stack_entry2.stack.account.update_column(:level, -20)

      result = project.users - [stack_entry.stack.account, stack_entry3.stack.account]
      result.must_equal []
    end
  end
end
