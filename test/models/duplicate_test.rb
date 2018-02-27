require 'test_helper'

class DuplicateTest < ActiveSupport::TestCase
  describe 'resolve!' do
    let(:good_project) { create(:project) }
    let(:bad_project) { create(:project) }
    let(:account_1) { create(:account) }
    let(:account_2) { create(:account) }

    it 'properly cleans up stack_entries' do
      stack = create(:stack)
      create(:stack_entry, stack: stack, project: good_project)
      bad_stack_entry_1 = create(:stack_entry, stack: stack, project: bad_project)
      bad_stack_entry_2 = create(:stack_entry, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      StackEntry.where(id: bad_stack_entry_1.id).first.deleted_at.wont_equal nil
      assert_nil StackEntry.where(id: bad_stack_entry_2.id).first.deleted_at
      StackEntry.where(id: bad_stack_entry_2.id).first.project_id.must_equal good_project.id
    end

    it 'properly cleans up ratings' do
      create(:rating, account: account_1, project: good_project)
      [account_1, account_2].map(&:verifications).map(&:destroy_all)
      bad_rating_1 = create(:rating, account: account_1, project: bad_project)
      bad_rating_2 = create(:rating, account: account_2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Rating.where(id: bad_rating_1.id).count.must_equal 0
      Rating.where(id: bad_rating_2.id).first.project_id.must_equal good_project.id
    end

    it 'properly cleans up reviews' do
      create(:review, account: account_1, project: good_project)
      bad_review_1 = create(:review, account: account_1, project: bad_project)
      bad_review_2 = create(:review, account: account_2, project: bad_project)
      helpful_review_1 = create(:helpful, review_id: bad_review_1.id)
      helpful_review_2 = create(:helpful, review_id: bad_review_2.id)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Review.where(id: bad_review_1.id).count.must_equal 0
      Helpful.where(id: helpful_review_1.id).count.must_equal 0
      Review.where(id: bad_review_2.id).first.project_id.must_equal good_project.id
      Helpful.where(id: helpful_review_2.id).count.must_equal 1
    end

    it 'properly cleans up links' do
      create(:link, url: 'http://pimentoloaf.com', link_category_id: 3, project: good_project)
      bad_link_1 = create(:link, url: 'http://pimentoloaf.com', link_category_id: 5, project: bad_project)
      bad_link_2 = create(:link, url: 'http://salami.com', link_category_id: 6, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Link.where(id: bad_link_1.id).first.deleted.must_equal true
      Link.where(id: bad_link_2.id).first.deleted.must_equal false
      Link.where(id: bad_link_2.id).first.project_id.must_equal good_project.id
    end

    it 'properly cleans up kudos' do
      name = create(:name)
      create(:kudo, sender: account_1, name: name, project: good_project)
      bad_kudo_1 = create(:kudo, sender: account_1, name: name, project: bad_project)
      bad_kudo_2 = create(:kudo, sender: account_2, name: name, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Kudo.where(id: bad_kudo_1.id).count.must_equal 0
      Kudo.where(id: bad_kudo_2.id).first.project_id.must_equal good_project.id
    end

    it 'properly cleans up aliases' do
      Project.any_instance.stubs(:code_locations).returns([])
      the_alias = create(:alias, project: bad_project)
      commit_name = the_alias.commit_name
      preferred_name = the_alias.preferred_name

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Alias.where(id: the_alias.id).first.deleted.must_equal true
      Alias.where(project: good_project, commit_name: commit_name, preferred_name: preferred_name).count.must_equal 1
    end

    it 'properly cleans up positions' do
      name_fact_1 = create(:name_fact, analysis: good_project.best_analysis)
      name_fact_2 = create(:name_fact, analysis: bad_project.best_analysis)
      name_fact_3 = create(:name_fact, analysis: bad_project.best_analysis)
      create(:position, name: name_fact_1.name, account: account_1, project: good_project)
      bad_position_1 = create(:position, name: name_fact_2.name, account: account_1, project: bad_project)
      bad_position_2 = create(:position, name: name_fact_3.name, account: account_2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      Position.where(id: bad_position_1.id).count.must_equal 0
      Position.where(id: bad_position_2.id).first.project_id.must_equal good_project.id
    end

    it 'properly cleans up enlistments' do
      VCR.use_cassette('multiple_enlistment_calls_with_code_location') do
        Enlistment.any_instance.stubs(:ensure_forge_and_job)
        WebMocker.delete_subscription
        unmocked_create_enlistment_with_code_location(good_project)
        bad_enlistment_1 = unmocked_create_enlistment_with_code_location(bad_project)
        bad_enlistment_2 = unmocked_create_enlistment_with_code_location(bad_project)
        code_location_id = bad_enlistment_2.code_location_id

        create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

        bad_enlistment_1.reload.deleted.must_equal true
        bad_enlistment_2.reload.deleted.must_equal true
        Enlistment.where(project: good_project, code_location_id: code_location_id).count.must_equal 1
      end
    end

    it 'properly cleans up project_experiences' do
      name_fact_1 = create(:name_fact, analysis: good_project.best_analysis)
      name_fact_2 = create(:name_fact, analysis: bad_project.best_analysis)
      name_fact_3 = create(:name_fact, analysis: bad_project.best_analysis)
      good_position = create(:position, name: name_fact_1.name, account: account_1, project: good_project)
      bad_position_1 = create(:position, name: name_fact_2.name, account: account_1, project: bad_project)
      bad_position_2 = create(:position, name: name_fact_3.name, account: account_2, project: bad_project)
      create(:project_experience, position: good_position, project: good_project)
      bad_project_experience_1 = create(:project_experience, position: bad_position_1, project: bad_project)
      bad_project_experience_2 = create(:project_experience, position: bad_position_2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      ProjectExperience.where(id: bad_project_experience_1.id).count.must_equal 0
      ProjectExperience.where(id: bad_project_experience_2.id).first.project_id.must_equal good_project.id
    end
  end

  describe 'validations' do
    it 'require a good_project' do
      duplicate = build(:duplicate, good_project: nil)
      duplicate.valid?.must_equal false
      duplicate.save
      duplicate.errors.messages.length.must_equal 1
      duplicate.errors.messages[:good_project].length.must_equal 1
    end

    it 'require a bad_project' do
      duplicate = build(:duplicate, bad_project: nil)
      duplicate.valid?.must_equal false
      duplicate.save
      duplicate.errors.messages.length.must_equal 1
      duplicate.errors.messages[:bad_project].length.must_equal 1
    end

    it 'require good_project and bad_project are different projects' do
      project = create(:project)
      duplicate = build(:duplicate, good_project: project, bad_project: project)
      duplicate.valid?.must_equal false
      duplicate.save
      duplicate.errors.messages.length.must_equal 1
      duplicate.errors.messages[:good_project].length.must_equal 1
    end

    it 'require good_project not having bet made a duplicate of another project' do
      duplicate1 = create(:duplicate)
      duplicate2 = build(:duplicate, good_project: duplicate1.bad_project)
      duplicate2.valid?.must_equal false
      duplicate2.save
      duplicate2.errors.messages.length.must_equal 1
      duplicate2.errors.messages[:good_project].length.must_equal 1
    end

    it 'require bad_project not already reported' do
      duplicate1 = create(:duplicate)
      duplicate2 = build(:duplicate, bad_project: duplicate1.good_project)
      duplicate2.valid?.must_equal false
      duplicate2.save
      duplicate2.errors.messages.length.must_equal 1
      duplicate2.errors.messages[:bad_project].length.must_equal 1
    end
  end
end
