require 'test_helper'

class AliasTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:project) { create(:project) }
  let(:name1)   { create(:name).id }
  let(:name2)   { create(:name).id }

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
    alias_obj = create(:alias)
    alias_project = Alias.for_project(alias_obj.project)
    alias_project.count.must_equal 1
    alias_project.first.must_equal alias_obj
  end

  it '#committer_names' do
    commit = create(:commit)
    create(:enlistment, repository: commit.code_set.repository, project: project)
    committer_names = Alias.committer_names(project)
    committer_names.first.id.must_equal commit.name_id
  end

  it '#preferred_names' do
    commit = create(:commit)
    create(:enlistment, repository: commit.code_set.repository, project: project)
    preferred_names = Alias.preferred_names(project)
    preferred_names.first.id.must_equal commit.name_id
  end

  it '#preferred_names with name_id' do
    commit = create(:commit)
    enlistment = create(:enlistment, repository: commit.code_set.repository)
    preferred_names = Alias.preferred_names(enlistment.project, commit.name_id)
    preferred_names.count.must_equal 0
  end

  it 'expected callbacks when alias is created' do
    Alias.any_instance.expects(:update_unclaimed_person).returns(true).once
    Alias.any_instance.expects(:schedule_project_analysis).returns(true).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).returns(true).never
    create(:alias)
  end

  it 'expected callbacks when alias preferred_name_id is modified' do
    alias_obj = create(:alias)
    Alias.any_instance.expects(:update_unclaimed_person).returns(true).never
    Alias.any_instance.expects(:schedule_project_analysis).returns(true).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).returns(true).once
    alias_obj.preferred_name = create(:name)
    alias_obj.save!
  end

  it 'expected callbacks when alias is destroyed' do
    alias_obj = create(:alias)
    Alias.any_instance.expects(:update_unclaimed_person).returns(true).once
    Alias.any_instance.expects(:schedule_project_analysis).returns(true).once
    Alias.any_instance.expects(:move_name_facts_to_preferred_name).returns(true).never
    alias_obj.destroy
  end

  it '#move_name_facts_to_preferred_name' do
    project = create(:project)
    contributor_fact = create(:contributor_fact, analysis: project.best_analysis, commits: 5, email_address_ids: [1])
    contributor_fact1 = create(:contributor_fact, analysis: project.best_analysis,
                                                  commits: 8, email_address_ids: [2, 1])
    contributor_fact2 = create(:contributor_fact, analysis: project.best_analysis, commits: 4, email_address_ids: [3])
    alias_obj = create(:alias, commit_name: contributor_fact.name,
                               project: project, preferred_name: contributor_fact1.name)
    contributor_fact1.reload.update_attributes!(commits: 8)
    alias_obj.preferred_name = contributor_fact2.name
    alias_obj.save!
    contributor_fact = ContributorFact.where(analysis_id: project.best_analysis_id)
    contributor_fact.find_by(name: contributor_fact1.name).commits.must_equal 3
    contributor_fact.find_by(name: contributor_fact1.name).email_address_ids.must_equal [2]
    contributor_fact.find_by(name: contributor_fact2.name).commits.must_equal 9
    contributor_fact.find_by(name: contributor_fact2.name).email_address_ids.must_equal [3, 1]
  end

  it '#best_analysis_aliases' do
    proj = create(:project)
    best = create(:analysis, project: proj)
    create(:analysis, project: proj)
    proj.update_columns(best_analysis_id: best.id)
    name1 = create(:name)
    name2 = create(:name)
    create(:analysis_alias, analysis: best, commit_name: name1, preferred_name: name2)
    aka = create(:alias, project: proj, commit_name: name1, preferred_name: name2)

    Alias.best_analysis_aliases(proj).to_a.map(&:id).sort.must_equal [aka.id]
  end

  it '#create_for_project creates a new alias' do
    alias_obj = Alias.create_for_project(account, project, name1, name2)
    alias_obj.must_be :persisted?
  end

  it '#create_for_project deletes an alias when one assigns an alias to have the same commit and preferred names' do
    Alias.create_for_project(account, project, name1, name2)
    alias_obj = Alias.create_for_project(account, project, name1, name1)
    alias_obj.deleted.must_equal true
  end

  it '#create_for_project restores an alias when flipped back' do
    Alias.create_for_project(account, project, name1, name2)
    Alias.create_for_project(account, project, name1, name1)
    alias_obj = Alias.create_for_project(account, project, name1, name2)
    alias_obj.deleted.must_equal false
  end

  it '#create_for_project with NO override bypasses validation' do
    Alias.any_instance.expects(:save!)
    Alias.create_for_project(account, project, name1, name2)
  end

  it '#create_for_project with override bypasses validation' do
    Alias.any_instance.expects(:save_without_validation!)
    Alias.create_for_project(account, project, name1, name2, true)
  end

  it 'allow_undo_to_nil?' do
    alias_record = create(:alias)
    assert alias_record.allow_undo_to_nil?(alias_record.preferred_name_id)
  end
end
