require 'test_helper'

class AliasTest < ActiveSupport::TestCase
  before do
    Alias.any_instance.stubs(:schedule_project_analysis)
    @account = create(:account)
    @project = create(:project)
    @commit_name = create(:name)
    @preferred_name = create(:name)
    @alias = create(:alias, project_id: @project.id, commit_name_id: @commit_name.id,
                            preferred_name_id: @preferred_name.id)

    enlistment = create_enlistment_with_code_location
    @commit = create(:commit)
    @commit.code_set.update!(code_location_id: enlistment.code_location_id)
    @commit_project = enlistment.project
  end

  it 'should validate commit_name_id presence' do
    alias_obj = build(:alias, commit_name: nil)
    alias_obj.valid?
    alias_obj.errors[:commit_name_id].count.must_equal 1
    alias_obj.errors[:commit_name_id].first.must_equal "can't be blank"
  end

  it 'should validate preferred_name_id presence' do
    alias_obj = build(:alias, preferred_name: nil)
    alias_obj.valid?
    alias_obj.errors[:preferred_name_id].count.must_equal 1
    alias_obj.errors[:preferred_name_id].first.must_equal "can't be blank"
  end

  it '#for_project' do
    alias_project = Alias.for_project(@alias.project)
    alias_project.count.must_equal 1
    alias_project.first.must_equal @alias
  end

  it '#committer_names' do
    committer_names = Alias.committer_names(@commit_project)
    committer_names.count.must_equal 1
    committer_names.first.id.must_equal @commit.name_id
  end

  it '#preferred_names' do
    preferred_names = Alias.preferred_names(@commit_project)
    preferred_names.count.must_equal 1
    preferred_names.first.id.must_equal @commit.name_id
  end

  it '#preferred_names with name_id' do
    preferred_names = Alias.preferred_names(@commit_project, @commit.name_id)
    preferred_names.count.must_equal 0
  end

  it 'expected callbacks when alias is created' do
    Alias.any_instance.expects(:update_unclaimed_person).once
    Alias.any_instance.expects(:schedule_project_analysis).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).never
    create(:alias)
  end

  it 'expected callbacks when alias preferred_name_id is modified' do
    Alias.any_instance.expects(:update_unclaimed_person).never
    Alias.any_instance.expects(:schedule_project_analysis).once
    Alias.any_instance.expects(:remove_unclaimed_person).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).once
    @alias.preferred_name = create(:name)
    @alias.save!
  end

  it 'expected callbacks when alias is destroyed' do
    Alias.any_instance.expects(:update_unclaimed_person).once
    Alias.any_instance.expects(:schedule_project_analysis).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).never
    @alias.destroy
  end

  it '#move_name_facts_to_preferred_name' do
    create(:contributor_fact, name_id: @commit_name.id, analysis_id: @project.best_analysis_id,
                              commits: 5, email_address_ids: [1])
    contributor_fact1 = create(:contributor_fact, name_id: @preferred_name.id, analysis_id: @project.best_analysis_id,
                                                  commits: 8, email_address_ids: [2, 1])
    contributor_fact2 = create(:contributor_fact, analysis_id: @project.best_analysis_id,
                                                  commits: 4, email_address_ids: [3])
    @alias.preferred_name_id = contributor_fact2.name_id
    @alias.save!
    contributor_fact = ContributorFact.where(analysis_id: @project.best_analysis_id)
    contributor_fact.find_by(name: contributor_fact1.name).commits.must_equal 3
    contributor_fact.find_by(name: contributor_fact1.name).email_address_ids.must_equal [2]
    contributor_fact.find_by(name: contributor_fact2.name).commits.must_equal 9
    contributor_fact.find_by(name: contributor_fact2.name).email_address_ids.must_equal [3, 1]
  end

  it '#best_analysis_aliases' do
    create(:analysis_alias, analysis_id: @project.best_analysis_id,
                            commit_name_id: @commit_name.id, preferred_name_id: @preferred_name.id)

    Alias.best_analysis_aliases(@project).to_a.map(&:id).sort.must_equal [@alias.id]
  end

  it '#create_for_project creates a new alias' do
    alias_obj = Alias.create_for_project(@account, @project, @commit_name.id, @preferred_name.id)
    alias_obj.must_be :persisted?
  end

  it '#create_for_project deletes an alias when one assigns an alias to have the same commit and preferred names' do
    Alias.create_for_project(@account, @project, @commit_name.id, @preferred_name.id)
    alias_obj = Alias.create_for_project(@account, @project, @commit_name.id, @commit_name.id)
    alias_obj.deleted.must_equal true
  end

  it '#create_for_project restores an alias when flipped back' do
    Alias.create_for_project(@account, @project, @commit_name.id, @preferred_name.id)
    Alias.create_for_project(@account, @project, @commit_name.id, @commit_name.id)
    alias_obj = Alias.create_for_project(@account, @project, @commit_name.id, @preferred_name.id)
    alias_obj.deleted.must_equal false
  end

  it '#create_for_project with NO override bypasses validation' do
    Alias.any_instance.expects(:save!)
    Alias.create_for_project(@account, @project, create(:name), @preferred_name.id)
  end

  it '#create_for_project with override bypasses validation' do
    Alias.any_instance.expects(:save_without_validation!)
    Alias.create_for_project(@account, @project, create(:name), @preferred_name.id, true)
  end

  it 'allow_undo_to_nil?' do
    assert @alias.allow_undo_to_nil?(@alias.preferred_name_id)
  end

  describe '#remove_unclaimed_person' do
    before do
      @person2 = create(:person, name_id: @alias.commit_name_id,
                                 project_id: @alias.project.id,
                                 name_fact: create(:contributor_fact, commits: 2))
      @person1 = create(:person, project_id: @alias.project.id)
      @contributor_fact = create(:contributor_fact, name_id: @alias.preferred_name_id,
                                                    analysis_id: @project.best_analysis_id,
                                                    commits: 8)
    end
    it 'should increment count only if preferred_name_id is changed ' do
      @alias.update_attributes(deleted: false)
      @contributor_fact.reload.commits.must_equal 8
    end

    it 'should increment count only if preferred_name_id is changed-positive' do
      contributor_fact1 = create(:contributor_fact, name_id: @person1.name_id, analysis_id: @project.best_analysis_id,
                                                    commits: 8)
      @alias.update_attributes(preferred_name_id: contributor_fact1.name_id)
      contributor_fact1.reload.commits.must_equal 10
    end
  end
end
