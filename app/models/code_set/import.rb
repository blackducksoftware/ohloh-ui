class CodeSet::Import
  IGNORED_FILES = %w(ohloh_token .gitignore)
  DEFAULT_COMMIT_COMMENT = '[no comment]'

  def initialize(code_set)
    @code_set = code_set
    @max_steps = 1
    @current_step = 0
  end

  def perform
    yield(@current_step, @max_steps)
    set_last_commit_options
    @max_steps = code_set.clump.scm.commit_count(@options) + 1

    code_set.clump.scm.each_commit(@options) { |scm_commit| create_commit_and_diffs(scm_commit, &block) }
    update_repository

    yield(@max_steps, @max_steps)
    @code_set
  end

  private

  def set_last_commit_options
    last_commit = @code_set.commits.last

    @options = {}
    @options[:after] = last_commit.sha1 if last_commit
  end

  def create_commit_and_diffs(scm_commit)
    Slave.local.sleep_while_busy

    increment_current_step(&block)

    commit = CodeSet::Commit.new(@code_set, scm_commit).find_or_create

    CodeSet::Diff.new(commit, scm_commit, @code_set).create_all
    @code_set.as_of = commit.position
    @code_set.save!
  end

  def increment_current_step
    @current_step += 1
    yield(@current_step, @max_steps)
  end

  def update_repository
    @code_set.repository.best_code_set_id = @code_set.id
    @code_set.repository.save(validate: false)
  end
end
