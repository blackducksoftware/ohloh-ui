# frozen_string_literal: true

require 'test_helper'

class TagTest < ActiveSupport::TestCase
  let(:project1) { create(:project) }
  let(:project2) { create(:project) }
  let(:account) { create(:account) }
  let(:language) { create(:language) }
  let(:tag1) { create(:tag, name: 'C++') }
  let(:tag2) { create(:tag, name: 'Ruby') }

  describe '#recalc_weight!' do
    it 'should update taggings_count and weight attribute' do
      assert_equal 1.0, tag1.weight
      assert_equal 0, tag1.taggings_count
      project1.tags = [tag1]
      assert_equal 1, tag1.taggings_count
    end

    it 'should not take into account deleted projects though tagged' do
      project1.tags = [tag1]
      project2.tags = [tag1]
      assert_equal 2, tag1.taggings_count
      project1.update_attribute :deleted, true
      assert_equal 1, tag1.taggings_count
    end

    it 'should increment taggings_count by 1 when tag a project' do
      assert_equal 0, tag1.taggings_count
      project1.tags = [tag1]
      assert_equal 1, tag1.taggings_count
      project2.tags = [tag1]
      assert_equal 2, tag1.taggings_count
    end

    it 'should decrement taggings_count by 1 when untag a project' do
      project1.tags = [tag1, tag2]
      assert_equal 1, tag1.taggings_count
      assert_equal 1, tag2.taggings_count
      project1.taggings.find_by(tag: tag2).destroy
      assert_equal 1, tag1.reload.taggings_count
      assert_equal 0, tag2.reload.taggings_count
    end
  end

  it 'must flag project for sync with KB when a tag is added' do
    assert_difference('KnowledgeBaseStatus.count', 1) do
      project1.tags = [tag1]
    end
    _(KnowledgeBaseStatus.find_by(project_id: project1.id).in_sync).must_equal false
  end
end
