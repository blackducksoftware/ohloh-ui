class CodeSet::Diff
  IGNORED_FILES = %w(ohloh_token .gitignore)

  def initialize(commit, scm_commit, code_set)
    @code_set = code_set
    @commit = commit
    @scm_commit = scm_commit
  end

  def create_all
    delete_ignored_files

    @scm_commit.diffs.each do |scm_diff|
      fyle = file_cache.find_or_create(scm_diff.path)
      create(scm_diff, fyle)
    end
  end

  private

  def delete_ignored_files
    return unless [SvnRepository, CvsRepository].include?(@code_set.repository.class)
    @scm_commit.diffs.delete_if { |diff| IGNORED_FILES.include?(diff.path) }
  end

  def file_cache
    @file_cache ||= FyleCache.new(@scm_commit, @code_set.id)
  end

  def create(scm_diff, fyle)
    # Something of a hack follows.
    # As a huge speed savings, Svn and Hg adapters do not provide SHA1 hashes of file contents.
    # However, Ohloh historically relied on these hashes to deduce the 'diff.added?' property.
    # To keep that working, we'll fill in NULL_SHA1 for the parent_sha1 in the case where the action is 'A'.
    Diff.create(commit_id: @commit.id, fyle_id: fyle.id, sha1: scm_diff.sha1,
                deleted: (scm_diff.action == 'D'),
                parent_sha1: scm_diff.parent_sha1 || (scm_diff.action == 'A' ? NULL_SHA1 : nil))
  end
end
