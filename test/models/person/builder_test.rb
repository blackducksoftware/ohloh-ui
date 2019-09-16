# frozen_string_literal: true

require 'test_helper'

class Person::BuilderTest < ActiveSupport::TestCase
  before { Rails.cache }

  describe 'rebuild_for_analysis_matching_names' do
    let(:project) { create(:project) }
    let(:analysis) { create(:analysis) }

    before do
      project.editor_account = create(:admin)
      project.update!(best_analysis_id: analysis.id)

      ContributorFact.where(analysis_id: analysis).destroy_all
    end

    describe 'names relative to project\'s best_analysis_id' do
      it 'must create people with related names' do
        contributor_fact = create(:contributor_fact, analysis_id: analysis.id)
        ContributorFact.unclaimed_for_project(project).to_a.map(&:id).must_equal [contributor_fact.id]

        assert_difference -> { Person.count }, 1 do
          Person::Builder.rebuild_for_analysis_matching_names(project)
        end
      end

      it 'must delete people with unrelated names' do
        unrelateable_name = create(:name_with_fact)
        unrelateable_person = Person.create!(name: unrelateable_name, project: project,
                                             name_fact: NameFact.find_by(name_id: unrelateable_name.id))

        Person::Builder.rebuild_for_analysis_matching_names(project)

        Person.find_by(id: unrelateable_person).must_be_nil
      end
    end

    it 'must fix contributor_fact associations by matching name_id' do
      matching_contributor_fact = create(:contributor_fact, analysis_id: project.best_analysis_id)
      person = Person.create!(name_id: matching_contributor_fact.name_id, project_id: project.id,
                              name_fact: create(:contributor_fact))
      person.name_fact_id.wont_equal matching_contributor_fact.id

      # Stub everthing before the private method call.
      Person.stubs(:delete_all)
      Person::Builder.stubs(:create_people_from_names)

      Person::Builder.rebuild_for_analysis_matching_names(project)

      person.reload
      person.name_fact_id.must_equal matching_contributor_fact.id
    end
  end

  describe 'rebuild_kudos' do
    let(:person) { create(:account).person }
    before { Person.where('id != ?', person.id).delete_all }

    it 'must attempt to find kudo_score' do
      KudoScore.expects(:find_by_account_or_name_and_project).once
      Person::Builder.rebuild_kudos
    end

    it 'must populate kudo related data when it is present' do
      kudo_score = stub(position: 7, score: 1, rank: 5)
      KudoScore.stubs(:find_by_account_or_name_and_project).returns(kudo_score)
      Person::Builder.rebuild_kudos

      person.reload
      person.kudo_rank.must_equal kudo_score.rank
      person.kudo_score.must_equal kudo_score.score
      person.kudo_position.must_equal kudo_score.position
      person.popularity_factor.to_f.must_equal person.searchable_factor
    end

    it 'must nullify kudo related data when it is absent' do
      KudoScore.stubs(:find_by_account_or_name_and_project)
      Person::Builder.rebuild_kudos

      person.reload
      person.kudo_rank.must_be_nil
      person.kudo_score.must_be_nil
      person.kudo_position.must_be_nil
      person.popularity_factor.must_equal 0.0
    end
  end
end
