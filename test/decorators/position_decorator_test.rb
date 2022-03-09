# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class PositionDecoratorTest < ActiveSupport::TestCase
  let(:admin) { create(:admin) }

  describe 'analyzed?' do
    it 'should return false when position is not analyzed' do
      create_position(account: admin)
      _(admin.positions.first.decorate.analyzed?).must_equal false
    end

    it 'should return true when position is analyzed' do
      account = create_account_with_commits_by_project
      _(account.positions.first.decorate.analyzed?).must_equal true
    end
  end

  describe 'affiliation' do
    it 'must return blank string when unaffiliated' do
      position = Position.new(affiliation_type: 'unaffiliated')
      _(position.decorate.affiliation).must_be_nil
    end

    it 'must return affiliated information affiliation is other and organization_name is present' do
      organization_name = Faker::Company.name
      position = Position.new(affiliation_type: 'other', organization_name: organization_name)

      expected_result = I18n.t('position.affiliated_with', name: organization_name)
      _(position.decorate.affiliation).must_equal expected_result
    end

    it 'must be blank when no organization and affiliation is neither unaffiliated or other' do
      position = Position.new(affiliation_type: nil)
      position.stubs(:affiliation).returns(stub(name: ''))
      _(position.decorate.affiliation).must_be_nil
    end

    it 'must return organization name when it is present' do
      organization_name = Faker::Company.name
      position = Position.new(organization_name: organization_name, affiliation_type: nil)

      expected_result = I18n.t('position.affiliated_with', name: position.organization)
      _(position.decorate.affiliation).must_equal expected_result
    end
  end

  describe 'stop_date' do
    it 'must return Present when effective_ongoing' do
      position = Position.new
      position.stubs(:effective_ongoing?).returns(true)
      _(position.decorate.stop_date).must_equal 'Present'
    end

    it 'must return formatted effective_stop_date when no effective_ongoing' do
      effective_stop_date = Date.current.end_of_month.advance(days: -5)
      position = Position.new(stop_date: effective_stop_date)
      position.stubs(:effective_ongoing?).returns(false)

      _(position.decorate.stop_date).must_equal effective_stop_date.strftime('%b %Y')
    end
  end

  describe '#name_fact' do
    it 'must get the correct name_fact' do
      project = create(:project)
      name = create(:name)
      name_fact = create(:name_fact, analysis: project.best_analysis, name: name)
      position = create(:position, project: project, name: name)

      _(position.decorate.name_fact).must_equal name_fact
    end
  end

  describe 'project_contributor_or_show_path' do
    it 'must return account position path when there are no contribution' do
      account = create(:account)
      position = create_position(account: account)
      position.stubs(:contribution)
      path = "/accounts/#{account.login}/positions/#{position.id}"
      _(position.decorate.project_contributor_or_show_path).must_equal path
    end

    it 'must return project contributior path when there is a contribution' do
      account = create(:account)
      account.person.destroy
      person = create(:person, account: account)
      contribution = person.contributions.first
      project = contribution.project
      position = create_position(account: account, project: project)

      path = "/p/#{project.vanity_url}/contributors/#{position.contribution.id}"
      _(account.positions.first.decorate.project_contributor_or_show_path).must_equal path
    end
  end

  describe 'new_and_has_null_description_title_and_organization' do
    it 'must return true when less than 1 hour old and certain attributes are nil' do
      Position.any_instance.stubs(:organization)
      position = create_position(description: nil, title: nil)
      _(position.decorate.new_and_has_null_description_title_and_organization?).must_equal true
    end
  end

  describe 'analyzed_class_name' do
    it 'must return data class when analyzed' do
      position = Position.new
      decorator = position.decorate
      decorator.stubs(:analyzed?).returns(true)
      _(decorator.analyzed_class_name).must_equal 'one-project data'
    end

    it 'must return no_data class when not analyzed' do
      position = Position.new
      decorator = position.decorate
      decorator.stubs(:analyzed?).returns(false)
      _(decorator.analyzed_class_name).must_equal 'one-project no_data'
    end
  end
end
