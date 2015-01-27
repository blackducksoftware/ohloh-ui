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
    create(:position, common_attributes.merge(project: project_foo))
    create(:position, common_attributes.merge(project: project_bar, title: :bar_title))
    create(:position, common_attributes.merge(project: nil))
    accounts(:admin).position_core.with_projects.count.must_equal 2

    accounts(:admin).positions.count.must_equal 3

    project_foo.update!(deleted: true)

    accounts(:admin).positions.count.must_equal 2
    accounts(:admin).positions.first.title.to_sym.must_equal :bar_title
    accounts(:admin).position_core.with_projects.count.must_equal 1
  end

  it '#ordered_positions' do
    # FIXME: unstub after integrating positions.
    Position.any_instance.stubs(:start_date_type)
    Position.any_instance.stubs(:start_date_type=)
    Position.any_instance.stubs(:stop_date_type)
    Position.any_instance.stubs(:stop_date_type=)
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

    create(:position, account: admin, project: next_most_recent_commit, name: name)
    create(:position, account: admin, project: most_recent_commit, name: name)
    create(:position, account: admin, project: no_commit_and_higher_character,
                      start_date_type: :manual, start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)
    create(:position, account: admin, project: oldest_commit, name: name)
    create(:position, account: admin, project: no_commit_and_lower_character,
                      start_date_type: :manual, start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)

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
    unactivated, scott, linux = accounts(:unactivated), names(:scott), projects(:linux)
    assert_difference('unactivated.positions.count', 1) do
      position = unactivated.position_core.ensure_position_or_alias!(linux, scott, true)
      linux.reload.aliases.count.must_equal 0
      position.project.name.must_equal 'Linux'
      # FIXME: uncomment after adding committer_name logic.
      # position.name.name.must_equal 'Scott'
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
    user, scott, linux = accounts(:user), names(:scott), projects(:linux)

    assert_difference('linux.aliases.count', 1) do
      analysis_stub = stub(name_fact_for: true)
      linux.stubs(:best_analysis).returns(analysis_stub)
      alias_stub = stub(project: linux, commit_name_id: scott.id,
                        preferred_name_id: names(:user).id)
      linux.stubs(:create_alias).returns(alias_stub)
      linux.aliases.stubs(:count).returns(1)

      alias_object = user.position_core.ensure_position_or_alias!(linux, scott)

      user.reload.positions.count.must_equal 1 # ensure no new positions
      alias_object.project.name.to_sym.must_equal :Linux
      alias_object.commit_name_id.must_equal scott.id
      alias_object.preferred_name_id.must_equal names(:user).id
    end
  end

  it 'ensure_position_or_alias deletes existing position and creates new if name is missing' do
    user, scott, linux = accounts(:user), names(:scott), projects(:linux)

    analysis_stub = stub(name_fact_for: false)
    linux.stubs(:best_analysis).returns(analysis_stub)
    Position.any_instance.stubs('committer_name=')
    Position.any_instance.stubs(:name).returns(scott)

    position = user.position_core.ensure_position_or_alias!(linux, scott)

    user.reload.positions.count.must_equal 1 # still one position
    position.name.name.to_sym.must_equal :Scott # but for the new name
    position.account_id.must_equal user.id
  end

  it 'logos returns a mapping of { logo_id: logo }' do
    position = create(:position)
    logos = position.account.position_core.logos
    logos.keys.first.must_equal position.project.logo.id
    logos.values.first.class.must_equal Logo
  end

  it '#with_only_unclaimed' do
    # user and admin both have names, joe - no
    Account::PositionCore.with_only_unclaimed.must_equal [accounts(:joe)]
  end
end
