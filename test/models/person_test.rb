require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  before { Rails.cache }

  describe 'searchable_factor' do
    let(:person) { create(:account).person }
    before { Person.count.must_equal(7) }

    it 'must return 0.0 when kudo_position is null' do
      person.kudo_position = nil
      person.searchable_factor.must_equal 0.0
    end

    it 'must return 0.0 when Person.cached_count is 1' do
      person.kudo_position = 5
      Person.stubs(:cached_count).returns(1)
      person.searchable_factor.must_equal 0.0
    end

    it 'must return a significantly lower value when no account_id' do
      person.account_id = nil
      person.kudo_position = 1
      person.searchable_factor.must_be_close_to 0.099
    end

    it 'must return valid value' do
      person.kudo_position = 1
      person.searchable_factor.must_be_close_to 1.0, 0.01

      person.kudo_position = 5
      person.searchable_factor.must_be_close_to 0.33, 0.01

      person.kudo_position = 7
      person.searchable_factor.must_be_close_to 0.0, 0.01
    end
  end

  it 'should set id to account id or random' do
    account = create(:account)
    assert_equal account.id, account.person.id

    person = create(:person)
    assert person.valid?
    assert_equal 107_374_182_41, person.id
  end

  it 'should set effective_name to an account name or name' do
    account = create(:account)
    assert_equal account.name, account.person.effective_name

    person = create(:person)
    assert_equal person.name.name, person.effective_name
  end

  it 'should set name fact' do
    person = create(:person)
    assert person.name_fact_id
  end

  it 'should not set name_fact when name_id is not present' do
    person = people(:jason)
    assert_nil person.name_fact_id
  end

  it 'should change effective_name when account name changed' do
    a = accounts(:user)
    assert_not_equal a.person.effective_name, a.name
    a.save!
    assert_equal a.person.reload.effective_name, a.name
  end

  it 'should cache person count' do
    assert_equal Person.cached_count, Person.count
    assert Person.cached_count > 0
    assert_no_difference 'Person.cached_count' do
      create(:person)
    end
  end

  it 'should cache claimed count' do
    create(:person)
    assert_equal 8, Person.count
    assert_equal 7, Person.cached_claimed_count
  end

  it 'should cache unclaimed count' do
    assert_equal 7, Person.count
    assert_equal 2, Person.cached_unclaimed_count
  end

  it '#find_claimed' do
    people = Person.find_claimed
    assert_equal 7, people.length
  end

  it '#find_claimed with pagination' do
    people = Person.find_claimed(page: 1, per_page: 5)
    assert_equal 5, people.length
    people = Person.find_claimed(page: 2, per_page: 5)
    assert_equal 2, people.length
  end

  it '#find_claimed with sort option' do
    admin, user = accounts(:admin), accounts(:user)
    Person.find_by_account_id(admin.id).update_attributes!(kudo_position: 1)
    Person.find_by_account_id(user.id).update_attributes!(kudo_position: 2)

    people = Person.find_claimed(sort_by: 'kudo_position')
    assert_equal 7, people.total_entries
    assert_equal admin.id, people[0].account_id
    assert_equal user.id, people[1].account_id
  end

  it '#find_claimed with search option' do
    people = Person.find_claimed(q: 'luckey')
    assert_equal 1, people.length
    assert_equal 1, people.total_entries
    assert_equal 2, people.first.account_id
  end

  it 'find_claimed without search option' do
    people = Person.find_claimed(page: 1, per_page: 3)
    assert_equal 3, people.length
    assert_equal 7, people.total_entries
  end

  it '#find_unclaimed' do
    people = Person.find_unclaimed
    assert_equal 2, people.length
    person = people.first.last.first
    assert_equal names(:joe), person.name
    assert_equal projects(:adium), person.project
  end

  it '#find_unclaimed with pagination' do
    people = Person.find_unclaimed(per_page: 1)
    assert_equal 1, people.length
  end

  it '#find_unclaimed with sort option' do
    people = Person.find_unclaimed
    assert_equal people(:joe), people.first.last.first
    assert_equal people(:kyle), people.last.last.first

    people(:joe).update_attribute(:kudo_position, 20)

    people = Person.find_unclaimed
    assert_equal people(:joe), people.last.last.first
    assert_equal people(:kyle), people.first.last.first
  end

  it '#find_unclaimed with search by name' do
    assert_equal 2, Person.find_unclaimed.length
    people = Person.find_unclaimed(q: 'joe')
    assert_equal 1, people.length
  end

  it '#find_unclaimed with search by email' do
    assert_equal 2, Person.find_unclaimed.length
    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    assert_equal 0, people.length

    create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    assert_equal 1, people.length
  end

  it '#find_unclaimed search by multiple emails' do
    create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com test1@test.com')
    assert_equal 1, people.length
    assert_equal names(:joe).id, people.first.first
  end

  it '#count_unclaimed' do
    assert_equal 2, Person.count_unclaimed
    assert_equal 1, Person.count_unclaimed('joe')
    assert_equal 0, Person.count_unclaimed('robinhood')
    assert_equal 0, Person.count_unclaimed('test@test.com', 'email')

    create_and_update_email_address_to_joe

    assert_equal 1, Person.count_unclaimed('test@test.com', 'email')
  end

  it 'should rebuild by project id' do
    assert_equal 2, Person.where(project_id: 2).count
    Person.rebuild_by_project_id(1)
    assert_equal 2, Person.where(project_id: 2).count
  end

  it 'deleting and restoring a project deletes and restores the persons associated with it' do
    skip('TODO: project model')
    with_editor(accounts(:jason)) do

      project = projects(:linux)
      delta = Person.find(:all, conditions: ['project_id = ?', project.id]).count

      assert_difference 'Person.count', delta * -1 do
        projects(:linux).destroy
      end
      assert_people
      assert_difference 'Person.count', delta do
        projects(:linux).create_edit.redo
      end
      assert_people
    end
  end

  it 'deleting a project removes the persons associated with it' do
    skip('TODO: project model')
    project = projects(:linux)
    delta = Person.find(:all, conditions: ['project_id = ?', project.id]).count

    assert_difference 'Person.count', delta * -1 do
      Project.delete(projects(:linux).id)
    end
    assert_people
  end

  it 'test_create_and_delete_position_with_name_id' do
    skip('TODO: position model')
    position = nil
    assert Person.find_by_project_id_and_name_id(projects(:linux).id, names(:scott).id)
    assert_difference 'Person.count', -1 do
      position = Position.create!(account: accounts(:kyle), project: projects(:linux), name: names(:scott))
    end
    assert_nil Person.find_by_project_id_and_name_id(projects(:linux).id, names(:scott).id)
    assert_difference 'Person.count', +1 do
      position.destroy
    end
    assert Person.find_by_project_id_and_name_id(projects(:linux).id, names(:scott).id)
    assert_people
  end

  it 'test_create_and_delete_position_without_name_id' do
    skip('TODO: position model')
    position = nil
    assert_no_difference 'Person.count' do
      position = Position.create!(account: accounts(:kyle),
                                  project: projects(:linux), start_date_type: :manual,
                                  start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)
    end
    assert_no_difference 'Person.count' do
      position.destroy
    end
    assert_people
  end

  it 'test_edit_position_adds_name_id' do
    skip('TODO: position model')
    position = positions(:joe_unclaimed) # Claims a project, but not a name
    assert Person.find_by_project_id_and_name_id(position.project_id, 3)
    assert_difference 'Person.count', -1 do
      position.name_id = 3
      position.save!
    end
    assert_nil Person.find_by_project_id_and_name_id(position.project_id, 3)
  end

  it 'test_edit_position_removes_name_id' do
    skip('TODO: position model')
    position = positions(:jason)
    name_id = position.name_id
    assert_nil Person.find_by_project_id_and_name_id(position.project_id, name_id)
    assert_difference 'Person.count', +1 do
      position.update_attributes(name: nil, start_date_type: :manual,
                                 start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)
    end
    assert Person.find_by_project_id_and_name_id(position.project_id, name_id)
  end

  it 'test_edit_position_changes_name_id' do
    skip('TODO: position model')
    position = positions(:jason)
    before_name_id = position.name_id
    after_name_id = 3
    assert_nil Person.find_by_project_id_and_name_id(position.project_id, before_name_id)
    assert Person.find_by_project_id_and_name_id(position.project_id, after_name_id)
    assert_no_difference 'Person.count' do
      position.update_attributes(name_id: after_name_id,
                                 start_date_type: :manual, start_date: Time.now,
                                 stop_date_type: :manual, stop_date: Time.now)
    end
    assert Person.find_by_project_id_and_name_id(position.project_id, before_name_id)
    assert_nil Person.find_by_project_id_and_name_id(position.project_id, after_name_id)
  end

  it 'test_setting_best_analysis_to_null_removes_all_names' do
    skip('TODO: project model')
    with_editor(accounts(:jason)) do
      projects(:linux).update_attributes(best_analysis_id: nil)
    end
    assert_people
  end

  it 'test_new_best_analysis_when_there_are_no_changes_to_names' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    with_editor(accounts(:jason)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test_new_best_analysis_when_a_new_name_is_created' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    ContributorFact.create!(analysis_id: new_analysis.id, name: Name.create(name: 'the new guy'))
    with_editor(accounts(:jason)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test_new_best_analysis_when_an_old_name_is_deleted' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    assert_difference 'ContributorFact.count', -1 do
      ContributorFact.find(:first, conditions: "analysis_id = #{new_analysis.id} AND name_id = #{names(:scott).id}")
        .destroy
    end
    with_editor(accounts(:jason)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test_searchable_factor' do
    skip('TODO: searchable plugin')

    assert_equal 9, Person.count

    people(:jason).kudo_position = 1
    assert_in_delta 1, people(:jason).searchable_factor, 0.01

    people(:jason).kudo_position = 5
    assert_in_delta 0.5, people(:jason).searchable_factor, 0.01

    people(:jason).kudo_position = 9
    assert_in_delta 0, people(:jason).searchable_factor, 0.01
  end

  it 'test_searchable_vector' do
    skip('TODO: searchable plugin')
    assert_equal 'Jason Allen jason', people(:jason).searchable_vector[:a_simple]
  end

  it 'find_claimed with search term' do
    skip('TODO: searchable plugin')
    robin, jason = accounts(:robin), accounts(:jason)
    Person.find_by_account_id(robin.id).update_attributes!(kudo_position: 10)
    Person.find_by_account_id(jason.id).update_attributes!(kudo_position: 12)

    people = Person.find_claimed(q: 'robin')

    assert_equal true, people.singleton_methods.include?(:query_parser)
    assert_equal 1, people.length
    assert_equal 1, people.total_entries
    assert_equal robin.id, people.first.account_id
  end

  it 'find_unclaimed when destroying positions' do
    skip('TODO: positions model')
    positions(:robin).destroy
    people = Person.find_unclaimed
    assert_equal 2, people.length
    people = people.map(&:last).flatten
    assert_equal 2, people.length
    assert people.any? { |p| p.name == names(:robin) }
  end

  it 'find_unclaimed when deleting project' do
    skip('TODO: project model')
    with_editor(:robin) do
      projects(:adium).update_attribute(:deleted, false)
      projects(:adium).analyze
    end
    people = Person.find_unclaimed
    assert_equal 2, people.length # still 2 unique names
    assert_equal 3, people.map(&:last).flatten.length # 3 people records
    assert_equal 2, people.detect { |k, _v| k == names(:robin).id }.last.length
    assert people.detect { |k, _v| k == names(:robin).id }.last.any? { |p| p.project == projects(:adium) }
  end

  private

  def create_and_update_email_address_to_joe
    ea = EmailAddress.create!(address: 'test@test.com')
    people(:joe).update_attribute(:name_fact, name_facts(:unclaimed))
    name_facts(:unclaimed).update_attribute(:email_address_ids, "{#{ea.id}}")
  end
end
