require 'test_helper'

class PositionCoreTest < ActiveSupport::TestCase
  it 'association callbacks on delegable' do
    accounts(:user).positions.count.must_equal 1
  end

  it '#with_projects'do
    Position.delete_all

    project_foo = create(:project, name: :foo, url_name: :foo)
    project_bar = create(:project, name: :bar, url_name: :bar)

    common_attributes = { account: accounts(:admin), start_date: Time.now, stop_date: Time.now }
    create_position(common_attributes.merge(project: project_foo))
    create_position(common_attributes.merge(project: project_bar, title: :bar_title))
    accounts(:admin).position_core.with_projects.count.must_equal 2

    accounts(:admin).positions.count.must_equal 2

    project_foo.update!(deleted: true)

    accounts(:admin).positions.count.must_equal 1
    accounts(:admin).positions.first.title.to_sym.must_equal :bar_title
    accounts(:admin).position_core.with_projects.count.must_equal 1
  end

  it '#ordered_positions' do
    skip 'FIXME: test failing due to a PG subquery error. Needs more research.'
    Position.delete_all

    # ActivityFact.delete_all
    admin = create(:admin)

    next_most_recent_commit = create(:project, name: :next_most_recent_commit)
    most_recent_commit = create(:project, name: :most_recent_commit)
    no_commit_and_higher_character = create(:project, name: :no_commit_and_higher_character)
    oldest_commit = create(:project, name: :oldest_commit)
    no_commit_and_lower_character = create(:project, name: :no_commit_and_lower_character)

    name = create(:name, name: :my_coding_nickname)
    create(:name_fact, name: name, analysis: next_most_recent_commit.best_analysis,
                       last_checkin: Time.now - 6.months)
    create(:name_fact, name: name, analysis: most_recent_commit.best_analysis,
                       last_checkin: Time.now - 1.months)
    create(:name_fact, name: name, analysis: oldest_commit.best_analysis,
                       last_checkin: Time.now - 12.months)

    create_position(account: admin, project: next_most_recent_commit, name: name)
    create_position(account: admin, project: most_recent_commit, name: name)
    create(:position, account: admin, project: no_commit_and_higher_character, name: nil,
                      start_date: Time.now, stop_date: Time.now)
    create_position(account: admin, project: oldest_commit, name: name)
    create(:position, account: admin, project: no_commit_and_lower_character, name: nil,
                      start_date: Time.now, stop_date: Time.now)

    returned_positions = admin.position_core.ordered.map { |p| p.project.name }
    expected_positions = %w(
      most_recent_commit
      next_most_recent_commit
      oldest_commit
      no_commit_and_higher_character
      no_commit_and_lower_character
    )
    returned_positions.must_equal expected_positions
  end

  it 'ensure_position_or_alias creates a position if try_create is set' do
    account, name, project = create(:account), create(:name), create(:project)
    NameFact.create!(analysis: project.best_analysis, name: name)
    assert_difference('account.positions.count', 1) do
      position = account.position_core.ensure_position_or_alias!(project, name, true)
      project.reload.aliases.count.must_equal 0
      position.project.name.must_equal project.name
      position.name.must_equal name
    end
  end

  it 'ensure_position_or_alias does not create a position by default' do
    unactivated, scott, linux = accounts(:unactivated), names(:scott), projects(:linux)
    assert_no_difference('unactivated.positions.count') do
      position = unactivated.position_core.ensure_position_or_alias!(linux, scott)
      position.must_be_nil
      linux.reload.aliases.count.must_equal 0 # still ensure no aliases
    end
  end

  it 'ensure_position_or_alias creates an alias if a position exists' do
    account, name, project = create(:account), create(:name), create(:project)
    create_position(account: account, project: project, name: name)
    new_name = create(:name)

    assert_difference('project.aliases.count', 1) do
      alias_stub = stub(project: project, commit_name_id: name.id,
                        preferred_name_id: new_name.id)
      project.stubs(:create_alias).returns(alias_stub)
      project.aliases.stubs(:count).returns(1)

      alias_object = account.position_core.ensure_position_or_alias!(project, name)

      account.reload.positions.count.must_equal 1 # ensure no new positions
      alias_object.project.name.must_equal project.name
      alias_object.commit_name_id.must_equal name.id
      alias_object.preferred_name_id.must_equal new_name.id
    end
  end

  it 'ensure_position_or_alias recreates position if name is missing' do
    account, name, project = create(:account), create(:name), create(:project)

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
    # user and admin both have names, joe - no
    Account::PositionCore.with_only_unclaimed.must_equal [accounts(:joe)]
  end
end
