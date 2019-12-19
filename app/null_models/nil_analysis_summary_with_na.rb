# frozen_string_literal: true

class NilAnalysisSummaryWithNa < NullObject
  def commits_count
    'N/A'
  end

  def committer_count
    'N/A'
  end

  def files_modified
    'N/A'
  end

  def lines_added
    'N/A'
  end

  def lines_removed
    'N/A'
  end
end
