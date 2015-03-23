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

  describe 'url cleanup' do
    it 'should clean up url value' do
      project.update_attributes(url: 'openhub.net/url_cleanup')
      project.reload.url.must_equal 'http://openhub.net/url_cleanup'
    end

    it 'should clean up url value' do
      project.update_attributes(download_url: 'openhub.net/download_url_cleanup')
      project.reload.download_url.must_equal 'http://openhub.net/download_url_cleanup'
    end

    it 'should require url value is a valid url if present' do
      project.update_attributes(url: 'I am a banana!')
      project.errors.messages[:url].must_equal [I18n.t(:not_a_valid_url)]
    end

    it 'should require url value is a valid url if present' do
      project.update_attributes(download_url: 'I am a banana!')
      project.errors.messages[:download_url].must_equal [I18n.t(:not_a_valid_url)]
    end
  end
end
