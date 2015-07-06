require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:project) { create(:project) }

  describe 'searchable_factor' do
    let(:person) { create(:account).person }
    before { Person.count.must_equal(7) }

    it 'must return 0.0 when kudo_position is null' do
      person.kudo_position = nil
      person.searchable_factor.must_equal 0.0
    end

    it 'must return 0.0 when Person.count is 1' do
      person.kudo_position = 5
      Person.stubs(:count).returns(1)
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
      person.searchable_factor.must_be_close_to 0.42, 0.01

      person.kudo_position = 7
      person.searchable_factor.must_be_close_to 0.14, 0.01
    end
  end

  it 'should set id to account id or random' do
    account = create(:account)
    account.person.id.must_equal account.id

    person = create(:person)
    assert person.valid?
    (person.id > 2_147_483_647).must_equal true
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

  it '#find_claimed' do
    people = Person.find_claimed(nil, nil)
    people.length.must_equal 7
  end

  it '#find_claimed with sort option' do
    admin, user = accounts(:admin), accounts(:user)
    admin.person.update!(kudo_position: 1)
    user.person.update!(kudo_position: 2)

    people = Person.find_claimed(nil, 'kudo_position')
    people.size.must_equal 7
    people[0].account_id.must_equal admin.id
    people[1].account_id.must_equal user.id
  end

  it '#find_claimed with search option' do
    people = Person.find_claimed('luckey', nil)
    people.length.must_equal 1
    people.size.must_equal 1
    people.first.account_id.must_equal 2
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

  it 'should rebuild by project id' do
    Person.where(project_id: 2).count.must_equal 2
    Person.rebuild_by_project_id(1)
    Person.where(project_id: 2).count.must_equal 2
  end

  it 'must delete all associated people when project is deleted' do
    project = create(:project)
    create(:person, project: project)

    assert_difference 'Person.count', -1 do
      project.destroy
    end
  end

  it 'must restore all deleted people when project is restored' do
    create(:person, project: project)
    project.destroy

    assert_difference 'Person.count', 1 do
      CreateEdit.find_by(target: project).redo!(account)
    end
  end

  it 'must destroy existing person on creating position' do
    name = create(:name)
    person = create(:person, name: name, project: project)

    create_position(account: account, project: project, name: name)

    Person.find_by(id: person.id).must_be_nil
  end

  it 'must create new person when position is destroyed' do
    name = create(:name)
    position = create_position(account: account, project: project, name: name)

    assert_difference 'Person.count', 1 do
      position.destroy
    end

    Person.find_by(project: project, name: name).must_be :present?
  end

  it 'wont affect person when position has no name and project' do
    account = create(:account)
    project = create(:project)

    assert_no_difference 'Person.count' do
      Position.create!(account: account, project: project,
                       start_date: Time.current, stop_date: Time.current)
    end

    assert_no_difference 'Person.count' do
      Position.last.destroy
    end
  end

  it 'must delete an existing person when matching name is updated' do
    position = Position.create!(account: account, project: project,
                                start_date: Time.current, stop_date: Time.current)
    person = create(:person, project: project)
    create(:name_fact, analysis: project.best_analysis, name: person.name)

    assert_difference 'Person.count', -1 do
      position.update!(name_id: person.name_id)
    end

    Person.find_by(id: person.id).must_be_nil
  end

  it 'must create new person when name is updated to null' do
    position = create_position
    name = position.name

    assert_difference 'Person.count', 1 do
      position.update!(name: nil, start_date: Time.current, stop_date: Time.current)
    end

    Person.find_by(project: position.project, name: name).must_be :present?
  end

  it 'must remove all names best_analysis is set to null' do
    skip('TODO: project model')
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis_id: nil)
    end
    assert_people
  end

  it 'test new best analysis when there are no changes to names' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test new best analysis when a new name is created' do
    skip('TODO: project model')
    old_analysis = projects(:linux).best_analysis
    new_analysis = duplicate_analysis(old_analysis)
    ContributorFact.create!(analysis_id: new_analysis.id, name: Name.create(name: 'the new guy'))
    with_editor(accounts(:admin)) do
      projects(:linux).update_attributes(best_analysis: new_analysis)
    end
    assert_people
  end

  it 'test new best analysis when an old name is deleted' do
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

    people = Person.find_claimed('luckey', nil)

    people.length.must_equal 1
    people.size.must_equal 1
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
    Person.find_unclaimed.length.must_equal 2
    project = create(:project, deleted: true)

    project.update!(deleted: false)

    Person.find_unclaimed.length.must_equal 2 # still 2 unique names
  end

  private

  def create_and_update_email_address_to_joe
    ea = EmailAddress.create!(address: 'test@test.com')
    people(:joe).update_attribute(:name_fact, name_facts(:unclaimed))
    name_facts(:unclaimed).update_attribute(:email_address_ids, "{#{ea.id}}")
  end
end
