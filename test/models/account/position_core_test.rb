require 'test_helper'

class PositionCoreTest < ActiveSupport::TestCase
  it 'association callbacks on delegable' do
    account = create(:account)
    create_position(account: account)
    account.positions.count.must_equal 1
  end

  it '#with_projects' do
    Position.delete_all

    admin = create(:admin)

    project_foo = create(:project, name: :foo, vanity_url: :foo)
    project_bar = create(:project, name: :bar, vanity_url: :bar)

    common_attributes = { account: admin, start_date: Time.current, stop_date: Time.current }
    create_position(common_attributes.merge(project: project_foo))
    create_position(common_attributes.merge(project: project_bar, title: :bar_title))
    admin.position_core.with_projects.count.must_equal 2

    admin.positions.count.must_equal 2

    project_foo.update!(deleted: true)

    admin.positions.count.must_equal 1
    admin.positions.first.title.to_sym.must_equal :bar_title
    admin.position_core.with_projects.count.must_equal 1
  end

  it 'ensure_position_or_alias creates a position if try_create is set' do
    account = create(:account)
    name = create(:name)
    project = create(:project)
    NameFact.create!(analysis: project.best_analysis, name: name)
    assert_difference('account.positions.count', 1) do
      position = account.position_core.ensure_position_or_alias!(project, name, true)
      project.reload.aliases.count.must_equal 0
      position.project.name.must_equal project.name
      position.name.must_equal name
    end
  end

  it 'ensure_position_or_alias does not create a position by default' do
    unactivated_account = create(:account, activated_at: nil)
    name = create(:name)
    project = create(:project)
    assert_no_difference('unactivated_account.positions.count') do
      position = unactivated_account.position_core.ensure_position_or_alias!(project, name)
      position.must_be_nil
      project.reload.aliases.count.must_equal 0 # still ensure no aliases
    end
  end

  it 'ensure_position_or_alias creates an alias if a position exists' do
    Project.any_instance.stubs(:code_locations).returns([])
    account = create(:account)
    person = create(:person)
    project = create(:project)
    name = create(:name)
    create_position(account: account, project: project, name: name)
    assert_difference 'Alias.count' do
      alias_obj = account.position_core.ensure_position_or_alias!(project, person.name)
      alias_obj.project_id.must_equal project.id
      alias_obj.commit_name_id.must_equal person.name_id
      alias_obj.preferred_name_id.must_equal name.id
    end
  end

  it 'ensure_position_or_alias update an alias if position and alias already exist' do
    Project.any_instance.stubs(:code_locations).returns([])
    account = create(:account)
    person = create(:person)
    project = create(:project)
    name = create(:name)
    create_position(account: account, project: project, name: name)
    alias_obj = create(:alias, project: project, commit_name: person.name)
    assert_no_difference 'Alias.count' do
      account.position_core.ensure_position_or_alias!(project, person.name)
      alias_obj.reload.deleted?.must_equal false
      alias_obj.preferred_name_id.must_equal name.id
    end
  end

  it 'ensure_position_or_alias delete an alias if preferred and existing name are same' do
    Project.any_instance.stubs(:code_locations).returns([])
    account = create(:account)
    project = create(:project)
    name = create(:name)
    create_position(account: account, project: project, name: name)
    alias_obj = create(:alias, project: project, commit_name: name)
    assert_no_difference 'Alias.count' do
      account.position_core.ensure_position_or_alias!(project, name)
      alias_obj.reload.deleted?.must_equal true
    end
  end

  it 'ensure_position_or_alias recreates position if name is missing' do
    account = create(:account)
    name = create(:name)
    project = create(:project)

    old_position = create_position(account: account, project: project, name: name)
    NameFact.find_by(name: name).destroy
    new_name = create(:name)
    create(:name_fact, analysis: project.best_analysis, name: new_name)
    new_position = account.position_core.ensure_position_or_alias!(project, new_name)

    account.reload.positions.count.must_equal 1
    new_position.wont_equal old_position
    new_position.name.must_equal new_name
    new_position.account.must_equal account
  end

  it 'logos returns a mapping of { logo_id: logo }' do
    position = create_position
    logos = position.account.position_core.logos
    logos.keys.first.must_equal position.project.logo.id
    logos.values.first.class.must_equal Logo
  end

  it '#with_only_unclaimed' do
    account = create(:account)
    create_position(account: account)
    account.positions.last.update_column(:name_id, nil)
    Account::PositionCore.with_only_unclaimed.must_equal [account]
  end

  describe '#name_facts' do
    it 'must return a sorted list of concatenated analysis_id and name_id' do
      project_foo = create(:project, name: :foo)
      project_bar = create(:project, name: :bar)

      name = create(:name)
      name_fact_1 = create(:name_fact, analysis: project_foo.best_analysis, name: name)
      name_fact_2 = create(:name_fact, analysis: project_bar.best_analysis, name: name)

      account = create(:account)
      create(:position, project: project_foo, name: name, account: account)
      create(:position, project: project_bar, name: name, account: account)

      account.position_core.name_facts.keys.must_equal(
        ["#{name_fact_1.analysis_id}_#{name.id}", "#{name_fact_2.analysis_id}_#{name.id}"]
      )
    end
  end

  describe '#ordered' do
    it 'must sort positions by name_fact.last_checkin when it is present' do
      project_foo = create(:project, name: :foo)
      project_bar = create(:project, name: :bar)

      name = create(:name)
      create(:name_fact, analysis: project_foo.best_analysis, name: name, last_checkin: 2.days.ago)
      create(:name_fact, analysis: project_bar.best_analysis, name: name, last_checkin: 1.day.ago)

      account = create(:account)
      position_1 = create(:position, project: project_foo, name: name, account: account)
      position_2 = create(:position, project: project_bar, name: name, account: account)

      account.position_core.ordered.must_equal [position_2, position_1]
    end

    it 'must sort positions by project_name when no name_fact' do
      project_foo = create(:project, name: :foo)
      project_bar = create(:project, name: :bar)

      name = create(:name)
      create(:name_fact, analysis: project_foo.best_analysis, name: name)
      create(:name_fact, analysis: project_bar.best_analysis, name: name)

      account = create(:account)
      position_foo = create(:position, project: project_foo, name: name, account: account)
      position_bar = create(:position, project: project_bar, name: name, account: account)

      Account::PositionCore.any_instance.stubs(:name_facts).returns({})
      account.position_core.ordered.must_equal [position_bar, position_foo]
    end
  end
end
