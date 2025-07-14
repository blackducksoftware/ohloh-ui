# frozen_string_literal: true

require 'test_helper'

class NameFactTest < ActiveSupport::TestCase
  it '#for_project' do
    proj = create(:project)
    best = create(:analysis, project: proj)
    proj.update_columns(best_analysis_id: best.id)
    nf = create(:name_fact, analysis: best)

    _(NameFact.for_project(proj).first.id).must_equal nf.id
  end

  it '#<=> operator' do
    nf2 = create(:name_fact, last_checkin: 2.days.ago)
    nf3 = create(:name_fact, last_checkin: 3.days.ago)
    nf1 = create(:name_fact, last_checkin: 1.day.ago)
    nf4 = create(:name_fact, last_checkin: nil)

    _([nf4, nf2, nf1, nf3].sort.map(&:id)).must_equal [nf1.id, nf2.id, nf3.id, nf4.id]
  end

  describe 'active' do
    it 'must be true when last_checkin is less than 1 year ago' do
      name_fact = NameFact.new(last_checkin: 11.months.ago)
      _(name_fact).must_be :active?
    end

    it 'wont be true when last checking is more than 1 year ago' do
      name_fact = NameFact.new(last_checkin: 1.year.ago)
      _(name_fact).wont_be :active?
    end
  end

  describe 'primary_language' do
    it 'must return a NilLanguage if it has no primary_language associated with it' do
      _(create(:name_fact, primary_language: nil).primary_language.is_a?(NilLanguage)).must_equal true
    end
  end

  describe 'with_positions' do
    it 'must exist if position found' do
      position = create_position
      positions = Position.where(NameFact.with_positions)
      _(positions.count).must_equal 1
      _(positions.first).must_equal position
    end
  end
end
