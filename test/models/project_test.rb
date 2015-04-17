require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:account) { create(:account) }

  describe 'hot' do
    it 'should return hot projects' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot.to_a.map(&:id).include?(proj.id).must_equal true
    end

    it 'should return hot projects with matching languages' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: 1)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot(1).to_a.map(&:id).include?(proj.id).must_equal true
    end

    it 'should not return hot projects without matching languages' do
      proj = create(:project, deleted: false)
      analysis = create(:analysis, project_id: proj.id, hotness_score: 999_999, main_language_id: 1)
      proj.update_attributes(best_analysis_id: analysis.id)
      Project.hot(2).to_a.map(&:id).include?(proj.id).must_equal false
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
  end
end
