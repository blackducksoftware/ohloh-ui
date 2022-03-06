# frozen_string_literal: true

require 'test_helper'

class DuplicateTest < ActiveSupport::TestCase
  describe 'resolve!' do
    let(:good_project) { create(:project) }
    let(:bad_project) { create(:project) }
    let(:account1) { create(:account) }
    let(:account2) { create(:account) }

    it 'properly cleans up stack_entries' do
      stack = create(:stack)
      create(:stack_entry, stack: stack, project: good_project)
      bad_stack_entry1 = create(:stack_entry, stack: stack, project: bad_project)
      bad_stack_entry2 = create(:stack_entry, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(StackEntry.where(id: bad_stack_entry1.id).first.deleted_at).wont_equal nil
      _(StackEntry.where(id: bad_stack_entry2.id).first.deleted_at).must_be_nil
      _(StackEntry.where(id: bad_stack_entry2.id).first.project_id).must_equal good_project.id
    end

    it 'properly cleans up ratings' do
      create(:rating, account: account1, project: good_project)
      [account1, account2].map(&:verifications).map(&:destroy_all)
      bad_rating1 = create(:rating, account: account1, project: bad_project)
      bad_rating2 = create(:rating, account: account2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Rating.where(id: bad_rating1.id).count).must_equal 0
      _(Rating.where(id: bad_rating2.id).first.project_id).must_equal good_project.id
    end

    it 'properly cleans up reviews' do
      create(:review, account: account1, project: good_project)
      bad_review1 = create(:review, account: account1, project: bad_project)
      bad_review2 = create(:review, account: account2, project: bad_project)
      helpful_review1 = create(:helpful, review_id: bad_review1.id)
      helpful_review2 = create(:helpful, review_id: bad_review2.id)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Review.where(id: bad_review1.id).count).must_equal 0
      _(Helpful.where(id: helpful_review1.id).count).must_equal 0
      _(Review.where(id: bad_review2.id).first.project_id).must_equal good_project.id
      _(Helpful.where(id: helpful_review2.id).count).must_equal 1
    end

    it 'properly cleans up links' do
      create(:link, url: 'http://pimentoloaf.com', link_category_id: 3, project: good_project)
      bad_link1 = create(:link, url: 'http://pimentoloaf.com', link_category_id: 5, project: bad_project)
      bad_link2 = create(:link, url: 'http://salami.com', link_category_id: 6, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Link.where(id: bad_link1.id).first.deleted).must_equal true
      _(Link.where(id: bad_link2.id).first.deleted).must_equal false
      _(Link.where(id: bad_link2.id).first.project_id).must_equal good_project.id
    end

    it 'properly cleans up kudos' do
      name = create(:name)
      create(:kudo, sender: account1, name: name, project: good_project)
      bad_kudo1 = create(:kudo, sender: account1, name: name, project: bad_project)
      bad_kudo2 = create(:kudo, sender: account2, name: name, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Kudo.where(id: bad_kudo1.id).count).must_equal 0
      _(Kudo.where(id: bad_kudo2.id).first.project_id).must_equal good_project.id
    end

    it 'properly cleans up aliases' do
      Project.any_instance.stubs(:code_locations).returns([])
      the_alias = create(:alias, project: bad_project)
      commit_name = the_alias.commit_name
      preferred_name = the_alias.preferred_name

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Alias.where(id: the_alias.id).first.deleted).must_equal true
      _(Alias.where(project: good_project, commit_name: commit_name, preferred_name: preferred_name).count).must_equal 1
    end

    it 'properly cleans up positions' do
      name_fact1 = create(:name_fact, analysis: good_project.best_analysis)
      name_fact2 = create(:name_fact, analysis: bad_project.best_analysis)
      name_fact3 = create(:name_fact, analysis: bad_project.best_analysis)
      create(:position, name: name_fact1.name, account: account1, project: good_project)
      bad_position1 = create(:position, name: name_fact2.name, account: account1, project: bad_project)
      bad_position2 = create(:position, name: name_fact3.name, account: account2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(Position.where(id: bad_position1.id).count).must_equal 0
      _(Position.where(id: bad_position2.id).first.project_id).must_equal good_project.id
    end

    it 'properly cleans up enlistments' do
      VCR.use_cassette('multiple_enlistment_calls_with_code_location') do
        Enlistment.any_instance.stubs(:ensure_forge_and_job)
        Enlistment.any_instance.stubs(:update_subscription)
        unmocked_create_enlistment_with_code_location(good_project)
        bad_enlistment1 = unmocked_create_enlistment_with_code_location(bad_project)
        bad_enlistment2 = unmocked_create_enlistment_with_code_location(bad_project)
        code_location_id = bad_enlistment2.code_location_id
        create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

        _(bad_enlistment1.reload.deleted).must_equal true
        _(bad_enlistment2.reload.deleted).must_equal true
        _(Enlistment.where(project: good_project, code_location_id: code_location_id).count).must_equal 1
      end
    end

    it 'properly cleans up project_experiences' do
      name_fact1 = create(:name_fact, analysis: good_project.best_analysis)
      name_fact2 = create(:name_fact, analysis: bad_project.best_analysis)
      name_fact3 = create(:name_fact, analysis: bad_project.best_analysis)
      good_position = create(:position, name: name_fact1.name, account: account1, project: good_project)
      bad_position1 = create(:position, name: name_fact2.name, account: account1, project: bad_project)
      bad_position2 = create(:position, name: name_fact3.name, account: account2, project: bad_project)
      create(:project_experience, position: good_position, project: good_project)
      bad_project_experience1 = create(:project_experience, position: bad_position1, project: bad_project)
      bad_project_experience2 = create(:project_experience, position: bad_position2, project: bad_project)

      create(:duplicate, good_project: good_project, bad_project: bad_project).resolve!(create(:admin))

      _(ProjectExperience.where(id: bad_project_experience1.id).count).must_equal 0
      _(ProjectExperience.where(id: bad_project_experience2.id).first.project_id).must_equal good_project.id
    end
  end

  describe 'validations' do
    it 'require a good_project' do
      duplicate = build(:duplicate, good_project: nil)
      _(duplicate.valid?).must_equal false
      duplicate.save
      _(duplicate.errors.messages.length).must_equal 1
      _(duplicate.errors.messages[:good_project].length).must_equal 1
    end

    it 'require a bad_project' do
      duplicate = build(:duplicate, bad_project: nil)
      _(duplicate.valid?).must_equal false
      duplicate.save
      _(duplicate.errors.messages.length).must_equal 1
      _(duplicate.errors.messages[:bad_project].length).must_equal 1
    end

    it 'require good_project and bad_project are different projects' do
      project = create(:project)
      duplicate = build(:duplicate, good_project: project, bad_project: project)
      _(duplicate.valid?).must_equal false
      duplicate.save
      _(duplicate.errors.messages.length).must_equal 1
      _(duplicate.errors.messages[:good_project].length).must_equal 1
    end

    it 'require good_project not having bet made a duplicate of another project' do
      duplicate1 = create(:duplicate)
      duplicate2 = build(:duplicate, good_project: duplicate1.bad_project)
      _(duplicate2.valid?).must_equal false
      duplicate2.save
      _(duplicate2.errors.messages.length).must_equal 1
      _(duplicate2.errors.messages[:good_project].length).must_equal 1
    end

    it 'require bad_project not already reported' do
      duplicate1 = create(:duplicate)
      duplicate2 = build(:duplicate, bad_project: duplicate1.good_project)
      _(duplicate2.valid?).must_equal false
      duplicate2.save
      _(duplicate2.errors.messages.length).must_equal 1
      _(duplicate2.errors.messages[:bad_project].length).must_equal 1
    end
  end
end
