# frozen_string_literal: true

require 'test_helper'

class ActivityFactByMonthQueryTest < ActiveSupport::TestCase
  let(:analysis) { create(:analysis, min_month: nil) }
  let(:nil_fact) { ActivityFactByMonthQuery.new(nil) }
  let(:analysis_fact) { ActivityFactByMonthQuery.new(analysis) }

  describe 'execute' do
    it 'should fail if analysis is nil' do
      proc { nil_fact.execute }.must_raise ActiveRecord::RecordNotFound
    end

    it 'should return [] if analysis min_month is nil' do
      assert_nil analysis.min_month
      analysis_fact.execute.must_equal []
    end

    it 'should return activity facts month by month' do
      analysis.update_column(:min_month, Date.current - 5.months)
      facts = []
      (1..5).to_a.each do |value|
        create(:all_month, month: Date.current - value.months)
        facts << create(:activity_fact, month: Date.current - value.months, analysis_id: analysis.id)
      end
      analysis_fact.execute.map(&:month).must_equal facts.map(&:month).reverse
    end
  end
end
