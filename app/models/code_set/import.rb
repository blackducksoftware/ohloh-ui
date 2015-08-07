class CodeSet::Import
  delegate :repository, :clump, to: :@code_set

  def initialize(code_set)
    @code_set = code_set
    @max_steps = 1
    @current_step = 0

    set_last_commit_options
  end

  def perform(&block)
    yield(@current_step, @max_steps)
    @max_steps = clump.scm.commit_count(@options) + 1

    clump.scm.each_commit(@options) { |scm_commit| create_commit_and_diffs(scm_commit, &block) }
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

  def create_commit_and_diffs(scm_commit, &block)
    increment_current_step(&block)

    commit = CodeSet::CommitFactory.new(@code_set, scm_commit, trunk_commit_tokens).find_or_create

    CodeSet::Diff.new(commit, scm_commit, @code_set).create_all
    @code_set.as_of = commit.position
    @code_set.save!
  end

  def increment_current_step
    @current_step += 1
    yield(@current_step, @max_steps)
  end

  def update_repository
    repository.best_code_set_id = @code_set.id
    repository.save(validate: false)
  end

  def trunk_commit_tokens
    @trunk_commit_tokens ||= @code_set.clump.scm.commit_tokens(@options.merge(trunk_only: true))
  end
end
