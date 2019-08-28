# frozen_string_literal: true

class NilAnalysisSummary < NullObject
  nought_methods :affiliated_committers_count, :affiliated_commits_count, :outside_committers_count,
                 :outside_commits_count, :commits_count, :committer_count, :commits_difference, :data?,
                 :committers_difference
end
