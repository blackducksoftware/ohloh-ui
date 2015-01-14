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

    it 'must return 0.0 when Person::Cached.count is 1' do
      person.kudo_position = 5
      Person::Cached.stubs(:count).returns(1)
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
    account.person.id.must_equal account.id

    person = create(:person)
    assert person.valid?
    person.id.must_equal 107_374_182_41
  end

  it 'should set effective_name to an account name or name' do
    account = create(:account)
    account.person.effective_name.must_equal account.name

    person = create(:person)
    person.effective_name.must_equal person.name.name
  end

  it 'should set name fact' do
    person = create(:person)
    assert person.name_fact_id
  end

  it 'should not set name_fact when name_id is not present' do
    person = people(:jason)
    person.name_fact_id.must_be_nil
  end

  it 'should change effective_name when account name changed' do
    a = accounts(:user)
    a.person.effective_name.wont_equal a.name
    a.save!
    a.name.must_equal a.person.reload.effective_name
  end

  it 'should cache claimed count' do
    create(:person)
    Person.count.must_equal 8
    Person::Cached.claimed_count.must_equal 7
  end

  it 'should cache unclaimed count' do
    Person.count.must_equal 7
    Person::Cached.unclaimed_count.must_equal 2
  end

  it '#find_claimed' do
    people = Person.find_claimed
    people.length.must_equal 7
  end

  it '#find_claimed with pagination' do
    people = Person.find_claimed(page: 1, per_page: 5)
    people.length.must_equal 5
    people = Person.find_claimed(page: 2, per_page: 5)
    people.length.must_equal 2
  end

  it '#find_claimed with sort option' do
    admin, user = accounts(:admin), accounts(:user)
    admin.person.update!(kudo_position: 1)
    user.person.update!(kudo_position: 2)

    people = Person.find_claimed(sort_by: 'kudo_position')
    people.total_entries.must_equal 7
    people[0].account_id.must_equal admin.id
    people[1].account_id.must_equal user.id
  end

  it '#find_claimed with search option' do
    people = Person.find_claimed(q: 'luckey')
    people.length.must_equal 1
    people.total_entries.must_equal 1
    people.first.account_id.must_equal 2
  end

  it 'find_claimed without search option' do
    people = Person.find_claimed(page: 1, per_page: 3)
    people.length.must_equal 3
    people.total_entries.must_equal 7
  end

  it '#find_unclaimed' do
    people = Person.find_unclaimed
    people.length.must_equal 2
    person = people.first.last.first
    person.name.must_equal names(:joe)
    person.project.must_equal projects(:adium)
  end

  it '#find_unclaimed with pagination' do
    people = Person.find_unclaimed(per_page: 1)
    people.length.must_equal 1
  end

  it '#find_unclaimed with sort option' do
    people = Person.find_unclaimed
    people.first.last.first.must_equal people(:joe)
    people.last.last.first.must_equal people(:kyle)

    people(:joe).update_attribute(:kudo_position, 20)

    people = Person.find_unclaimed
    people.last.last.first.must_equal people(:joe)
    people.first.last.first.must_equal people(:kyle)
  end

  it '#find_unclaimed with search by name' do
    Person.find_unclaimed.length.must_equal 2
    people = Person.find_unclaimed(q: 'joe')
    people.length.must_equal 1
  end

  it '#find_unclaimed with search by email' do
    Person.find_unclaimed.length.must_equal 2
    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    people.length.must_equal 0

    create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    people.length.must_equal 1
  end

  it '#find_unclaimed search by multiple emails' do
    create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com test1@test.com')
    people.length.must_equal 1
    people.first.first.must_equal names(:joe).id
  end

  it '#count_unclaimed' do
    Person.count_unclaimed.must_equal 2
    Person.count_unclaimed('joe').must_equal 1
    Person.count_unclaimed('robinhood').must_equal 0
    Person.count_unclaimed('test@test.com', 'email').must_equal 0

    create_and_update_email_address_to_joe

    Person.count_unclaimed('test@test.com', 'email').must_equal 1
  end

  it 'should rebuild by project id' do
    Person.where(project_id: 2).count.must_equal 2
    Person.rebuild_by_project_id(1)
    Person.where(project_id: 2).count.must_equal 2
  end

  it 'deleting and restoring a project deletes and restores the persons associated with it' do
    skip('TODO: project model')
    with_editor(accounts(:admin)) do

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
    Person.find_by(project: projects(:linux), name: names(:scott)).must_be :present?
    assert_difference 'Person.count', -1 do
      position = Position.create!(account: accounts(:kyle), project: projects(:linux), name: names(:scott))
    end
    Person.find_by(project: projects(:linux), name: names(:scott)).must_be_nil
    assert_difference 'Person.count', +1 do
      position.destroy
    end
    Person.find_by(project: projects(:linux), name: names(:scott)).must_be :present?
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
    Person.find_by(project: position.project, name: 3).must_be :present?
    assert_difference 'Person.count', -1 do
      position.name_id = 3
      position.save!
    end
    Person.find_by(project: position.project, name: 3).must_be_nil
  end

  it 'test_edit_position_removes_name_id' do
    skip('TODO: position model')
    position = positions(:admin)
    name_id = position.name_id
    Person.find_by(project: position.project, name: name_id).must_be_nil
    assert_difference 'Person.count', +1 do
      position.update_attributes(name: nil, start_date_type: :manual,
                                 start_date: Time.now, stop_date_type: :manual, stop_date: Time.now)
    end
    Person.find_by(project_id: position.project_id, name_id: name_id).must_be :present?
  end

  it 'test_edit_position_changes_name_id' do
    skip('TODO: position model')
    position = positions(:admin)
    before_name_id = position.name_id
    after_name_id = 3
    Person.find_by(project_id: position.project_id, name_id: before_name_id).must_be_nil
    Person.find_by(project_id: position.project_id, name_id: after_name_id).must_be :present?
    assert_no_difference 'Person.count' do
      position.update_attributes(name_id: after_name_id,
                                 start_date_type: :manual, start_date: Time.now,
                                 stop_date_type: :manual, stop_date: Time.now)
    end
    Person.find_by(project_id: position.project_id, name_id: before_name_id).must_be :present?
    Person.find_by(project_id: position.project_id, name_id: after_name_id).must_be_nil
  end

  it 'test_setting_best_analysis_to_null_removes_all_names' do
    skip('TODO: project model')
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis_id: nil)
    end
    assert_people
  end

  it 'test_new_best_analysis_when_there_are_no_changes_to_names' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test_new_best_analysis_when_a_new_name_is_created' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    ContributorFact.create!(analysis_id: new_analysis.id, name: Name.create(name: 'the new guy'))
    with_editor(accounts(:admin)) do
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
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test_searchable_vector' do
    people(:jason).searchable_vector[:a].must_equal 'admin Allen admin'
  end

  it 'find_claimed with search term' do
    user, admin = accounts(:user), accounts(:admin)
    user.person.update_columns(kudo_position: 10)
    admin.person.update_columns(kudo_position: 12)

    people = Person.find_claimed(q: 'luckey')

    people.length.must_equal 1
    people.total_entries.must_equal 1
    people.first.account_id.must_equal user.id
  end

  it 'find_unclaimed when destroying positions' do
    Person.find_unclaimed.count.must_equal 2
    position = positions(:user)
    position.destroy
    Person.create!(project: position.project, name: position.name, name_fact: create(:contributor_fact))
    name_fact_id_and_people = Person.find_unclaimed
    name_fact_id_and_people.length.must_equal 3
    people = name_fact_id_and_people.map(&:last).flatten
    people.length.must_equal 3
    assert people.any? { |p| p.name == names(:user) }
  end

  it 'find_unclaimed when deleting project' do
    skip('TODO: project model')
    with_editor(:user) do
      projects(:adium).update_attribute(:deleted, false)
      projects(:adium).analyze
    end
    people = Person.find_unclaimed
    people.length.must_equal 2 # still 2 unique names
    people.map(&:last).flatten.length.must_equal 3  # 3 people records
    people.detect { |k, _v| k == names(:user).id }.last.length.must_equal 2
    people.detect { |k, _v| k == names(:user).id }.last.find { |p| p.project == projects(:adium) }.must_be :present?
  end

  it 'should return claimed persons when availabale when page is not given' do
    claimed_persons = Person.claimed

    claimed_persons.length.must_equal 7
    account_ids = claimed_persons.map(&:account_id).compact
    account_ids.size.must_equal 7
  end

  it 'should return claimed persons when availabale when page is 2' do
    Person.stubs(:per_page).returns(5)
    claimed_persons = Person.claimed(2)

    claimed_persons.length.must_equal 2
    account_ids = claimed_persons.map(&:account_id).compact
    account_ids.size.must_equal 2
  end

  private

  def create_and_update_email_address_to_joe
    ea = EmailAddress.create!(address: 'test@test.com')
    people(:joe).update_attribute(:name_fact, name_facts(:unclaimed))
    name_facts(:unclaimed).update_attribute(:email_address_ids, "{#{ea.id}}")
  end
end
