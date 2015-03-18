require 'test_helper'

class PositionDecoratorTest < ActiveSupport::TestCase
  let(:user) { accounts(:user) }
  let(:admin) { accounts(:admin) }

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  describe 'analyzed?' do
    it 'should return false when position is not analyzed' do
      admin.positions.first.decorate.analyzed?.must_equal false
    end

    it 'should return true when position is analyzed' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.positions.first.decorate.analyzed?.must_equal true
    end
  end

  describe 'affiliation' do
    it 'must return blank string when unaffiliated' do
      position = Position.new(affiliation_type: 'unaffiliated')
      position.decorate.affiliation.must_be_nil
    end

    it 'must return affiliated information affiliation is other and organization_name is present' do
      organization_name = Faker::Company.name
      position = Position.new(affiliation_type: 'other', organization_name: organization_name)

      expected_result = I18n.t('position.affiliated_with', name: organization_name)
      position.decorate.affiliation.must_equal expected_result
    end

    it 'must be blank when no organization and affiliation is neither unaffiliated or other' do
      position = Position.new(affiliation_type: nil)
      position.stubs(:affiliation).returns(stub(name: ''))
      position.decorate.affiliation.must_be_nil
    end

    it 'must return organization name when it is present' do
      organization_name = Faker::Company.name
      position = Position.new(organization_name: organization_name, affiliation_type: nil)

      expected_result = I18n.t('position.affiliated_with', name: position.organization)
      position.decorate.affiliation.must_equal expected_result
    end
  end

  describe 'stop_date' do
    it 'must return Present when effective_ongoing' do
      position = Position.new
      position.stubs(:effective_ongoing?).returns(true)
      position.decorate.stop_date.must_equal 'Present'
    end

    it 'must return formatted effective_stop_date when no effective_ongoing' do
      effective_stop_date = Date.today.end_of_month.advance(days: -5)
      position = Position.new(stop_date: effective_stop_date)
      position.stubs(:effective_ongoing?).returns(false)

      position.decorate.stop_date.must_equal effective_stop_date.strftime('%b %Y')
    end
  end
end
