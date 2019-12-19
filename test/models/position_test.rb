# frozen_string_literal: true

require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:project) { create(:project) }
  let(:name_obj) { create(:name) }

  describe :scopes do
    it 'claimed_by' do
      create_position(account: account, name: name_obj)

      positions = Position.claimed_by(account)

      positions.count.must_equal 1
      positions.first.account_id.must_equal account.id
      positions.first.name_id.must_be :present?
    end

    it 'for_project' do
      project = create(:project)
      position = create_position(project: project, name: name_obj)

      Position.for_project(project).first.must_equal position
    end

    describe 'active' do
      it 'must return records with contributor_fact' do
        position = create_position(project: project, name: name_obj)

        project.positions.active.must_include position
      end

      it 'wont return records without contributor fact' do
        position = create_position(project: project, name: name_obj)
        project.best_analysis.contributor_facts.destroy_all

        project.positions.active.wont_include position
      end
    end
  end

  describe :create do
    it 'must create a valid position object' do
      project_firebug = create(:project, name: :firebug)
      project_draper = create(:project, name: :draper)
      project_squeel = create(:project, name: :squeel)

      name = create(:name)
      language = create(:language)
      create(:name_fact, analysis: project_firebug.best_analysis, name: name)

      valid_params = {
        account_id: account.id,
        project_oss: project_firebug.name,
        committer_name: name.name,
        title: :SDE,
        language_exp: [language.id.to_s],
        description: 'worked hard.',
        affiliation_type: :other,
        organization_name: :Microsoft,
        project_experiences_attributes: {
          0 => { project_name: project_squeel.name },
          1 => { project_name: project_draper.name }
        }
      }

      p = Position.create!(valid_params)
      position = Position.find(p.id)

      position.account.must_equal account
      position.project.must_equal project_firebug
      position.name.must_equal name
      position.title.must_equal 'SDE'
      position.language_experiences.size.must_equal 1
      position.language_experiences[0].language.must_equal language
      position.start_date.must_be_nil
      position.stop_date.must_be_nil
      position.affiliation_type.must_equal 'other'
      position.description.must_equal 'worked hard.'
      position.project_experiences.size.must_equal 2

      position.project_experiences.find_by(project_id: project_squeel.id).must_be :present?
      position.project_experiences.find_by(project_id: project_draper).must_be :present?
    end

    it 'must create language_experiences' do
      language_ids = [create(:language).id.to_s, create(:language).id.to_s]
      position = create_position(language_exp: language_ids, name: name_obj)

      position.must_be :persisted?
      position.language_experiences.size.must_equal 2
    end

    # This test is to note that:
    # Nested attributes can be updated with the same values simultaneously regardless of uniqueness validation.
    it 'must create duplicate project_experiences when updated together' do
      project_draper = create(:project, name: :draper)
      position = create_position(
        project_experiences_attributes: {
          0 => { project_name: project_draper.name },
          1 => { project_name: project_draper.name }
        }
      )

      position.must_be :persisted?
      position.project_experiences.map(&:project).map(&:name).sort.must_equal %w[draper draper]
    end

    it 'must assign a project using a project name' do
      create(:name_fact, analysis: project.best_analysis, name: name_obj)
      position = create(:position, project: nil, project_oss: project.name, name: name_obj)

      position.must_be :persisted?
      position.project.must_equal project
    end

    it 'must save affiliation' do
      organization = create(:organization)
      position = create_position(name: name_obj, organization_id: organization.id,
                                 affiliation_type: :specified)
      position.reload

      position.organization_id.must_equal organization.id
      position.affiliation_type.must_equal 'specified'
      position.organization_name.must_be_nil
      position.affiliation.name.must_equal organization.name
    end
  end

  describe 'one_monther?' do
    it 'must be false if ongoing' do
      position = Position.new(ongoing: true)
      position.one_monther?.must_equal false
    end

    it 'must be false when start and stop dates are in different months' do
      position = Position.new(ongoing: true, start_date: 1.month.ago, stop_date: Date.current)
      position.one_monther?.must_equal false
    end

    it 'must be false when start and stop dates are in different years' do
      position = Position.new(ongoing: true, start_date: 1.year.ago, stop_date: Date.current)
      position.one_monther?.must_equal false
    end

    it 'must be true when start and stop dates are in the same month and year' do
      start_date = Date.current.beginning_of_month.advance(days: 5)
      stop_date = Date.current.end_of_month.advance(days: -5)
      position = Position.new(ongoing: false, start_date: start_date, stop_date: stop_date)
      position.one_monther?.must_equal true
    end
  end

  describe '#effective_start_date' do
    it 'must return start date when present' do
      start_date = 1.month.ago
      position = Position.new(start_date: start_date)
      position.effective_start_date.must_equal start_date
    end

    it 'must return name_fact.first_checkin when it is present' do
      position = Position.new
      name_fact = stub(first_checkin: 3.days.ago)
      position.stubs(:name_fact).returns(name_fact)
      position.effective_start_date.must_equal name_fact.first_checkin
    end
  end

  describe '#effective_stop_date' do
    it 'must return stop date when present' do
      stop_date = 1.month.ago
      position = Position.new(stop_date: stop_date)
      position.effective_stop_date.must_equal stop_date
    end

    it 'must return current utc time when ongoing' do
      position = Position.new(ongoing: true)
      Time.stub :now, stub(utc: 1.minute.ago) do
        position.effective_stop_date.must_equal Time.current
      end
    end

    it 'must return current utc time when name_fact is active' do
      position = Position.new
      name_fact = stub(active?: true)
      position.stubs(:name_fact).returns(name_fact)
      Time.stub :current, stub(utc: 1.minute.ago) do
        position.effective_stop_date.must_equal Time.current
      end
    end

    it 'must return time in current timezone when name_fact has last_checkin' do
      position = Position.new
      name_fact = stub(last_checkin: 1.day.ago)
      position.stubs(:name_fact).returns(name_fact)
      Time.stub :current, 1.day.ago do
        position.effective_stop_date.to_i.must_equal Time.current.to_i
      end
    end
  end

  describe '#effective_ongoing?' do
    it 'must be true when ongoing' do
      position = Position.new(ongoing: true)
      position.effective_ongoing?.must_equal true
    end

    it 'must be false when no stop_date and name_fact not active' do
      position = Position.new
      name_fact = stub(active?: false)
      position.stubs(:name_fact).returns(name_fact)
      position.effective_ongoing?.must_equal false
    end
  end

  describe '#active?' do
    it 'must return true when effective_ongoing and no stop_date' do
      position = Position.new
      position.stubs(:effective_ongoing?).returns(true)
      position.active?.must_equal true
    end

    it 'must return false when no effective_ongoing' do
      position = Position.new
      position.stubs(:effective_ongoing?).returns(false)
      position.active?.must_equal false
    end

    it 'must return false when stop_date is in the past' do
      position = Position.new(stop_date: 1.day.ago)
      position.stubs(:effective_ongoing?).returns(true)
    end
  end

  describe '#organization' do
    it 'must return organization_name when present' do
      organization_name = Faker::Company.name
      position = Position.new(organization_name: organization_name)
      position.organization.must_equal organization_name
    end

    it 'must return affiliation.name when it is present' do
      affiliation_name = Faker::Company.name
      position = Position.new
      position.stubs(:affiliation).returns(stub(name: affiliation_name))
      position.organization.must_equal affiliation_name
    end
  end

  describe '#effective_duration' do
    it 'must return a difference between effective_stop_date and effective_start_date' do
      effective_start_date = Date.current.beginning_of_month.advance(days: 5)
      effective_stop_date = Date.current.end_of_month.advance(days: -5)
      position = Position.new
      position.stubs(:effective_start_date).returns(effective_start_date)
      position.stubs(:effective_stop_date).returns(effective_stop_date)
      position.effective_duration.must_equal(effective_stop_date - effective_start_date)
    end
  end

  describe '#committer_name' do
    it 'must set name to passed committer_name associated name record' do
      project = create(:project)
      NameFact.create!(analysis: project.best_analysis, name: name_obj)

      position = build(:position, committer_name: name_obj.name, project: project)

      position.must_be :valid?
      position.name.must_equal name_obj
    end
  end

  describe '#contribution_id' do
    it 'must return nil when no name_id' do
      position = Position.new
      position.contribution_id.must_be_nil
    end

    it 'must call id generator function when name_id is present' do
      position = Position.new(name: create(:name))
      Contribution.expects(:generate_id_from_project_id_and_name_id).once
      position.contribution_id
    end
  end
end
