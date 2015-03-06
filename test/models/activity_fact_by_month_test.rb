require 'test_helper'

class ActivityFactByMonthTest < ActiveSupport::TestCase
  let(:analysis) { create(:analysis) }
  let(:nil_fact) { ActivityFactByMonth.new(nil) }
  let(:analysis_fact) { ActivityFactByMonth.new(analysis) }

  describe 'result' do
    it 'should fail if analysis is nil' do
      proc { nil_fact.result }.must_raise ActiveRecord::RecordNotFound
    end

    it 'should return [] if analysis min_month is nil' do
      analysis.min_month.must_equal nil
      analysis_fact.result.must_equal []
    end

    it 'should return activity facts month by month' do
      analysis.update_column(:min_month, Date.today - 5.months)
      facts = []
      (1..5).to_a.each do |value|
        create(:all_month, month: Date.today - value.months)
        facts << create(:activity_fact, month: Date.today - value.months, analysis_id: analysis.id)
      end
      analysis_fact.result.map(&:month).must_equal facts.map(&:month).reverse
    end
  end
end
