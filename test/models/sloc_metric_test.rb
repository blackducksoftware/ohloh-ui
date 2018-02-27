require 'test_helper'

class SlocMetricTest < ActiveSupport::TestCase
  before do
    sloc_metric = create(:sloc_metric, code_added: 2, code_removed: 1)
    @diff = sloc_metric.diff
    sloc_metric.diff.commit.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
    sloc_metric.sloc_set.update_attributes(code_set_id: sloc_metric.diff.fyle.code_set_id)
    @analysis_sloc_set = create(:analysis_sloc_set, sloc_set_id: sloc_metric.sloc_set_id)
  end

  describe 'commit_summaries' do
    it 'should return sloc metric commit summaries' do
      summary = SlocMetric.commit_summaries(@diff.commit, @analysis_sloc_set.analysis_id)
      summary.length.must_equal 1
      summary.first.code_added.must_equal 2
      summary.first.code_removed.must_equal 1
    end

    it 'should not return if file is ignored' do
      CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
      @analysis_sloc_set.update_attributes(ignore: "Disallow: #{@diff.fyle.name}")
      summary = SlocMetric.commit_summaries(@diff.commit, @analysis_sloc_set.analysis_id)
      summary.length.must_equal 0
    end
  end

  describe 'diff_summaries' do
    it 'should return sloc metric of diffs summaries' do
      summary = SlocMetric.diff_summaries(@diff, @analysis_sloc_set.analysis_id)
      summary.length.must_equal 1
      summary.first.code_added.must_equal 2
      summary.first.code_removed.must_equal 1
    end
  end
end
