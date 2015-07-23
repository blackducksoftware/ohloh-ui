class FyleCache
  MAX_CACHE_SIZE = 1000

  def initialize(scm_commit, code_set_id)
    @code_set_id = code_set_id
    set_cache(scm_commit)
  end

  def find_or_create(path)
    @cached.find_by(name: path) || Fyle.find_or_create_by(name: path, code_set_id: @code_set_id)
  end

  private

  def set_cache(scm_commit)
    paths = scm_commit.diffs[0..MAX_CACHE_SIZE].map(&:path)
    @cached = Fyle.where(code_set_id: @code_set_id, name: paths).limit(MAX_CACHE_SIZE)
  end
end
