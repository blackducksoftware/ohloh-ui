require 'test_helper'

class PositionsCoreTest < ActiveSupport::TestCase
  fixtures :accounts, :projects, :names

  def setup
    fixup
  end

  test 'association callbacks on delegable' do
    assert_equal 1, accounts(:user).positions.count
  end

  test '#with_projects'do
    Position.delete_all

    with_editor(:admin) do
      project_foo = create(:project, name: :foo, url_name: :foo)
      project_bar = create(:project, name: :bar, url_name: :bar)

      common_attributes = { account: accounts(:admin), start_date: Time.now, stop_date: Time.now }
      create(:position, common_attributes.merge(project: project_foo))
      create(:position, common_attributes.merge(project: project_bar, title: :bar_title))
      create(:position, common_attributes.merge(project: nil))
      assert_equal 2, accounts(:admin).positions_core.with_projects.count

      assert_equal 3, accounts(:admin).positions.count

      project_foo.update!(deleted: true)

      assert_equal 2, accounts(:admin).positions.count
      assert_equal :bar_title, accounts(:admin).positions.first.title.to_sym
      assert_equal 1, accounts(:admin).positions_core.with_projects.count
    end
  end

  test '#ordered_positions' do
    # FIXME: unstub after integrating positions.
    Position.any_instance.stubs(:start_date_type)
    Position.any_instance.stubs(:start_date_type=)
    Position.any_instance.stubs(:stop_date_type)
    Position.any_instance.stubs(:stop_date_type=)
    Position.delete_all

    # ActivityFact.delete_all
    admin = accounts(:admin)

    with_editor(admin) do
      create(:project, name: :next_most_recent_commit)
      create(:project, name: :most_recent_commit)
      create(:project, name: :no_commit_and_higher_character)
      create(:project, name: :oldest_commit)
      create(:project, name: :no_commit_and_lower_character)
      project = -> name { Project.find_by_name(name) }

      analysis_a = create(:analysis, project: project.call(:next_most_recent_commit), logged_at: '20010-01-01')
      analysis_b = create(:analysis, project: project.call(:most_recent_commit), logged_at: '20010-01-01')
      analysis_d = create(:analysis, project: project.call(:oldest_commit), logged_at: '20010-01-01')

      project.call(:next_most_recent_commit).update_attribute(:best_analysis_id, analysis_a.id)
      project.call(:most_recent_commit).update_attribute(:best_analysis_id, analysis_b.id)
      project.call(:oldest_commit).update_attribute(:best_analysis_id, analysis_d.id)

      name = create(:name, name: :my_coding_nickname)
      create(:name_fact, name: name, analysis_id: project.call(:next_most_recent_commit).best_analysis_id,
                         last_checkin: Time.now - 6.months)
      create(:name_fact, name: name, analysis_id: project.call(:most_recent_commit).best_analysis_id,
                         last_checkin: Time.now - 1.months)
      create(:name_fact, name: name, analysis_id: project.call(:oldest_commit).best_analysis_id,
                         last_checkin: Time.now - 12.months)

      create(:position, account: admin, project: project.call(:next_most_recent_commit), name: name)
      create(:position, account: admin, project: project.call(:most_recent_commit), name: name)
      create(:position, account: admin, project: project.call(:no_commit_and_higher_character),
                        start_date_type: :manual, start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)
      create(:position, account: admin, project: project.call(:oldest_commit), name: name)
      create(:position, account: admin, project: project.call(:no_commit_and_lower_character),
                        start_date_type: :manual, start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)

      returned_positions = admin.positions_core.ordered.map { |p| p.project.name }
      expected_positions = %w(
        most_recent_commit
        next_most_recent_commit
        oldest_commit
        no_commit_and_higher_character
        no_commit_and_lower_character
      )
      assert_equal expected_positions, returned_positions
    end
  end

  test 'ensure_position_or_alias creates an alias if a position exists' do
    user, scott, linux = accounts(:user), names(:scott), projects(:linux)

    assert_difference('linux.aliases.count', 1) do
      analysis_stub = stub(name_fact_for: true)
      linux.stubs(:best_analysis).returns(analysis_stub)
      alias_stub = stub(project: linux, commit_name_id: scott.id,
                        preferred_name_id: names(:user).id)
      linux.stubs(:create_alias).returns(alias_stub)
      linux.aliases.stubs(:count).returns(1)

      alias_object = with_editor(:admin) { user.positions_core.ensure_position_or_alias!(linux, scott) }

      assert_equal 1, user.reload.positions.count # ensure no new positions
      assert_equal :Linux, alias_object.project.name.to_sym
      assert_equal scott.id, alias_object.commit_name_id
      assert_equal names(:user).id, alias_object.preferred_name_id
    end
  end

  test 'ensure_position_or_alias deletes existing position and creates new if name is missing' do
    user, scott, linux = accounts(:user), names(:scott), projects(:linux)

    analysis_stub = stub(name_fact_for: false)
    linux.stubs(:best_analysis).returns(analysis_stub)
    Position.any_instance.stubs('committer_name=')
    Position.any_instance.stubs(:name).returns(scott)

    position = user.positions_core.ensure_position_or_alias!(linux, scott)

    assert_equal 1, user.reload.positions.count # still one position
    assert_equal :Scott, position.name.name.to_sym # but for the new name
    assert_equal user.id, position.account_id
  end

  test 'logos returns a mapping of { logo_id: logo }' do
    logos = accounts(:user).positions_core.logos
    assert_equal 1, logos.keys.first
    assert_equal Logo, logos.values.first.class
  end
end
