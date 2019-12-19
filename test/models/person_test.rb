# frozen_string_literal: true

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }
  let(:project) { create(:project) }
  let(:person) { account.person }

  describe 'searchable_factor' do
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
      create(:person)
      person.account_id = nil
      person.kudo_position = 1
      person.searchable_factor.must_be_close_to 0.099
    end

    it 'must return valid value' do
      6.times { create(:account) }

      person.kudo_position = 1
      person.searchable_factor.must_be_close_to 1.0, 0.01

      person.kudo_position = 5
      person.searchable_factor.must_be_close_to 0.42, 0.01

      person.kudo_position = 7
      person.searchable_factor.must_be_close_to 0.14, 0.01
    end
  end

  it 'should set id to account id or random' do
    account.person.id.must_equal account.id

    person = create(:person)
    assert person.valid?
    (person.id > 2_147_483_647).must_equal true
  end

  it 'should set effective_name to an account name or name' do
    account.person.effective_name.must_equal account.name

    person = create(:person)
    person.effective_name.must_equal person.name.name
  end

  it 'should set name fact' do
    person = create(:person)
    assert person.name_fact_id
  end

  it 'should not set name_fact when name_id is not present' do
    account.person.update!(name_id: nil)
    person.name_fact_id.must_be_nil
  end

  it 'should change effective_name when account name changed' do
    account.name.must_equal account.person.effective_name
    account.update(name: 'new_name_test')
    account.person.effective_name.must_equal 'new_name_test'
  end

  it '#find_claimed' do
    admin.person
    account.person
    people = Person.find_claimed(nil, nil)
    people.length.must_equal 3
  end

  it '#find_claimed with sort option' do
    Person.destroy_all
    admin.person.update!(kudo_position: 1)
    account.person.update!(kudo_position: 2)

    people = Person.find_claimed(nil, 'kudo_position')
    people.size.must_equal 2
    people[0].account.must_equal admin
    people[1].account.must_equal account
  end

  it '#find_claimed with search option' do
    people = Person.find_claimed(account.login, nil)
    people.length.must_equal 1
    people.size.must_equal 1
    people.first.account_id.must_equal account.id
  end

  it '#find_unclaimed' do
    create(:person)
    create(:person)

    people = Person.find_unclaimed
    people.length.must_equal 2
  end

  it '#find_unclaimed with pagination' do
    create(:person)
    people = Person.find_unclaimed(per_page: 1)
    people.length.must_equal 1
  end

  it '#find_unclaimed with sort option' do
    Person.destroy_all
    person1 = create(:person)
    person2 = create(:person)
    person3 = create(:person)

    person1.update_attribute(:kudo_position, 5)
    person2.update_attribute(:kudo_position, 10)
    person3.update_attribute(:kudo_position, 20)

    people = Person.find_unclaimed
    people[0].last.first.must_equal person1
    people[1].last.first.must_equal person2
    people[2].last.first.must_equal person3
  end

  it '#find_unclaimed with search by name' do
    create(:person, effective_name: 'joe')
    create(:person)
    Person.find_unclaimed.length.must_equal 2
    people = Person.find_unclaimed(q: 'joe')
    people.length.must_equal 1
  end

  it '#find_unclaimed with search by email' do
    create(:person)
    create(:person)
    Person.find_unclaimed.length.must_equal 2
    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    people.length.must_equal 0

    create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com')
    people.length.must_equal 1
  end

  it '#find_unclaimed search by multiple emails' do
    person = create_and_update_email_address_to_joe

    people = Person.find_unclaimed(find_by: 'email', q: 'test@test.com test1@test.com')
    people.length.must_equal 1
    people.first.first.must_equal person.name_id
  end

  it 'should rebuild by project id' do
    create(:person, project_id: project.id)
    create(:person, project_id: project.id)
    Person.where(project_id: project.id).count.must_equal 2
    Person.rebuild_by_project_id(create(:project).id)
    Person.where(project_id: project.id).count.must_equal 2
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

  it 'test_searchable_vector' do
    account.person.searchable_vector[:a].must_equal "#{account.name} #{account.login}"
  end

  it 'find_claimed with search term' do
    account.person.update_columns(kudo_position: 10)
    admin.person.update_columns(kudo_position: 12)

    people = Person.find_claimed(admin.login, nil)

    people.length.must_equal 1
    people.size.must_equal 1
    people.first.account_id.must_equal admin.id
  end

  it 'find_unclaimed when destroying positions' do
    create(:person)
    create(:person)
    name = create(:name)

    account.person.update(name: name)
    Person.find_unclaimed.count.must_equal 3

    position = create_position(account: account)
    position.destroy
    person = Person.find_by(name_id: name.id)

    people = Person.find_unclaimed
    people.length.must_equal 4
    people.map(&:last).flatten.any? { |p| p.name == person.name }.must_equal true
  end

  it 'find_unclaimed when deleting project' do
    create(:person)
    create(:person)
    Person.find_unclaimed.length.must_equal 2
    project = create(:project, deleted: true)

    project.update!(deleted: false)

    Person.find_unclaimed.length.must_equal 2 # still 2 unique names
  end

  private

  def create_and_update_email_address_to_joe
    ea = EmailAddress.create!(address: 'test@test.com')
    name_fact = create(:name_fact)
    person = create(:person, name_fact: name_fact)
    name_fact.update_attribute(:email_address_ids, "{#{ea.id}}")
    person
  end
end
