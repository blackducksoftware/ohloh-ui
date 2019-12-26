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
    it 'should return the json data for KB' do
      Enlistment.any_instance.stubs(:code_location).returns(code_location_stub_with_id)
      data = JSON.parse knowledge_base_status.json_message
      data['ohloh_id'].must_equal project.id
      data['deleted'].must_equal project.deleted
      data['user_count'].must_equal project.user_count
      data['logo'].wont_be_empty
    end
  end
end
