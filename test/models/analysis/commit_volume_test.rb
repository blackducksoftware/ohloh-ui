# frozen_string_literal: true

require 'test_helper'

class Analysis::CommitVolumeTest < ActiveSupport::TestCase
  describe 'collection' do
    before do
      analysis_sloc_set = FactoryBot.create(:analysis_sloc_set, as_of: 1)
      @analysis = analysis_sloc_set.analysis

      commit = FactoryBot.create(:commit, code_set: analysis_sloc_set.sloc_set.code_set,
                                          position: 0)
      @analysis_alias = create(:analysis_alias, commit_name: commit.name, analysis: @analysis)
    end

    it 'must return preferred_name and commit count' do
      results = Analysis::CommitVolume.new(@analysis, '2 months').collection

      _(results.first[0]).must_equal @analysis_alias.preferred_name.name
      _(results.first[1]).must_equal 1
    end
  end
end
