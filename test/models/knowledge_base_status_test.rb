# frozen_string_literal: true

require 'test_helper'

class KnowledgeBaseStatusTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:knowledge_base_status) { KnowledgeBaseStatus.find_by(project_id: project.id) }

  describe '.items_to_sync' do
    it 'should return empty if no iterm to sync' do
      KnowledgeBaseStatus.items_to_sync.must_be_empty
    end

    it 'should return result if there is item to sync' do
      project
      KnowledgeBaseStatus.items_to_sync.wont_be_empty
    end
  end

  describe '.enable_sync!' do
    it 'must flag for KB sync' do
      knowledge_base_status.update_attributes(in_sync: true)
      KnowledgeBaseStatus.enable_sync!(project.id)
      knowledge_base_status.reload.in_sync.must_equal false
    end
  end

  describe '#json_message' do
    before do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub_with_id)
    end

    it 'should return the json data for KB' do
      data = JSON.parse knowledge_base_status.json_message
      data['ohloh_id'].must_equal project.id
      data['deleted'].must_equal project.deleted
      data['user_count'].must_equal project.user_count
      data['logo'].wont_be_empty
    end

    it 'should return tag details in the json data' do
      project.tag_list = 'c++ Google_Apps'
      data = JSON.parse knowledge_base_status.json_message
      data['tags'].sort.must_equal ['Google_Apps', 'c++']
    end

    it 'should return enlistment details in the json data' do
      create(:enlistment, project: project, ignore: 'Ignored!')
      data = JSON.parse knowledge_base_status.json_message
      data['enlistments'].wont_be_empty
    end

    it 'should return link details in the json data' do
      link = create(:link, project_id: project.id)
      data = JSON.parse knowledge_base_status.json_message
      data['links'].wont_be_empty
      data['links'][0]['id'].must_equal link.id
    end

    it 'should return project license details in the json data' do
      create(:project_license, project: project)
      data = JSON.parse knowledge_base_status.json_message
      data['licenses'].wont_be_empty
    end

    it 'should return project forge match in the json data' do
      forge = Forge.find_by(name: 'Github')
      project.update_attributes(forge_id: forge.id)
      data = JSON.parse knowledge_base_status.json_message
      data['forge'].wont_be_empty
      data['forge']['forge_id'].must_equal forge.id
    end

    it 'should return commit and contributor details in the json data' do
      create(:analysis_with_multiple_activity_facts, project: project)
      (1..3).to_a.each do |value|
        create(:all_month, month: Date.current - value.month)
      end
      data = JSON.parse knowledge_base_status.json_message
      data['best_analysis']['commit_activity'].wont_be_empty
      data['best_analysis']['commit_activity']['data'].wont_be_empty
      data['best_analysis']['contributor_activity'].wont_be_empty
      data['best_analysis']['contributor_activity']['data'].wont_be_empty
    end
  end
end
