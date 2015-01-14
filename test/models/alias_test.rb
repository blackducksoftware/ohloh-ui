require 'test_helper'

class AliasTest < ActiveSupport::TestCase
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

  test '#create_for_project creates a new alias' do
    account = create(:account)
    project = create(:project)
    name1 = create(:name)
    name2 = create(:name)
    a = Alias.create_for_project(account, project, name1, name2)
    a.persisted?.must_equal true
  end

  test '#create_for_project deletes an alias when one assigns an alias to have the same commit and preferred names' do
    account = create(:account)
    project = create(:project)
    name1 = create(:name)
    name2 = create(:name)
    Alias.create_for_project(account, project, name1, name2)
    a = Alias.create_for_project(account, project, name1, name1)
    a.deleted.must_equal true
  end

  test '#create_for_project restores an alias when flipped back' do
    account = create(:account)
    project = create(:project)
    name1 = create(:name)
    name2 = create(:name)
    Alias.create_for_project(account, project, name1, name2)
    Alias.create_for_project(account, project, name1, name1)
    a = Alias.create_for_project(account, project, name1, name2)
    a.deleted.must_equal false
  end

  test '#create_for_project with NO override bypasses validation' do
    account = create(:account)
    project = create(:project)
    name1 = create(:name)
    name2 = create(:name)
    Alias.any_instance.expects(:save!)
    Alias.create_for_project(account, project, name1, name2)
  end

  test '#create_for_project with override bypasses validation' do
    account = create(:account)
    project = create(:project)
    name1 = create(:name)
    name2 = create(:name)
    Alias.any_instance.expects(:save_without_validation!)
    Alias.create_for_project(account, project, name1, name2, true)
  end
end
